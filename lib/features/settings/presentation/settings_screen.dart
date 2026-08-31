import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/websocket_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/app_providers.dart';
import '../domain/app_settings_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _backendUrlController;
  final BiometricService _biometricService = BiometricService();

  // Settings State Flags
  bool _isTestingConnection = false;
  bool? _isBackendReachable;
  String _connectionStatusText = 'FastAPI Engine: Ready';
  int _latencyMs = 18;

  // Configuration Switches
  bool _biometricsEnabled = true;
  bool _pushNotifications = true;
  bool _criticalOnly = false;
  bool _dailyDigest = true;
  bool _soundHaptics = false;
  bool _localEncryption = true;
  bool _isDemoMode = AppConfig.isDemoMode;
  bool _githubConnected = true;
  bool _wazuhConnected = true;
  String _themeMode = 'dark';

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController(text: AppConfig.apiBaseUrl);
    _loadInitialSettings();
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSettings() async {
    try {
      final settings = await ref.read(settingsRepositoryProvider).loadSettings();
      if (mounted) {
        setState(() {
          _backendUrlController.text = settings.backendUrl;
          _biometricsEnabled = settings.biometricAuthEnabled;
          _pushNotifications = settings.pushNotificationsEnabled;
          _criticalOnly = settings.criticalAlertsOnly;
          _dailyDigest = settings.dailyDigestEnabled;
          _soundHaptics = settings.soundHapticsEnabled;
          _localEncryption = settings.encryptedLocalStorage;
          _isDemoMode = settings.isDemoMode;
          _githubConnected = settings.githubConnected;
          _wazuhConnected = settings.wazuhConnected;
          _themeMode = settings.themeMode;
        });
        if (!settings.isDemoMode) {
          _testBackendConnection(silent: true);
        }
      }
    } catch (_) {}
  }

  Future<void> _persistSettings() async {
    final model = AppSettingsModel(
      backendUrl: _backendUrlController.text.trim(),
      biometricAuthEnabled: _biometricsEnabled,
      pushNotificationsEnabled: _pushNotifications,
      criticalAlertsOnly: _criticalOnly,
      dailyDigestEnabled: _dailyDigest,
      soundHapticsEnabled: _soundHaptics,
      encryptedLocalStorage: _localEncryption,
      themeMode: _themeMode,
      isDemoMode: _isDemoMode,
      githubConnected: _githubConnected,
      wazuhConnected: _wazuhConnected,
    );
    await ref.read(settingsRepositoryProvider).saveSettings(model);
  }

  Future<void> _saveBackendUrl() async {
    final newUrl = _backendUrlController.text.trim();
    if (newUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Backend URL'),
          backgroundColor: AppColors.critical,
        ),
      );
      return;
    }

    AppConfig.apiBaseUrl = newUrl;
    ref.read(apiClientProvider).updateBaseUrl(newUrl);
    await _persistSettings();
    if (!_isDemoMode) {
      await _testBackendConnection();
      ref.read(webSocketServiceProvider).connect();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('FastAPI Endpoint updated: $newUrl')),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _testBackendConnection({bool silent = false}) async {
    final targetUrl = _backendUrlController.text.trim();
    if (targetUrl.isEmpty) return;

    setState(() {
      _isTestingConnection = true;
      _connectionStatusText = 'Probing $targetUrl...';
    });

    final client = ref.read(apiClientProvider);
    final result = await client.checkHealth(targetUrl: targetUrl);

    if (mounted) {
      setState(() {
        _isTestingConnection = false;
        _isBackendReachable = result.isReachable;
        _latencyMs = result.latencyMs;
        _connectionStatusText = result.message;
      });

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  result.isReachable ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.isReachable
                        ? 'FastAPI Server Reachable • Latency: ${result.latencyMs}ms'
                        : 'Backend Offline at $targetUrl. Switch to Demo Mode if offline.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: result.isReachable ? AppColors.success : AppColors.critical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (value) {
      final isSupported = await _biometricService.isBiometricAvailable();
      if (!isSupported && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric hardware not available or enrolled on this device.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    setState(() => _biometricsEnabled = value);
    await _persistSettings();
  }

  Future<void> _handleLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppColors.cardBorderRadius,
          side: BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 24),
            const SizedBox(width: 10),
            Text('End Enterprise Session?', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'You will be signed out of the SecureGuard SOC platform. Any unsaved triage state will be cleared.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.critical,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) {
        context.go(AppRouter.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;

    final isOnline = !_isDemoMode && _isBackendReachable == true;
    final String appBarStatusText = _isDemoMode
        ? 'DEMO MODE'
        : (isOnline ? 'SOC ONLINE' : (_isBackendReachable == false ? 'DISCONNECTED' : 'LIVE API'));
    final StatusType appBarStatusType = _isDemoMode
        ? StatusType.warning
        : (isOnline ? StatusType.normal : StatusType.critical);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SGAppBar(
        title: AppStrings.navSettings,
        subtitle: 'Enterprise Platform Preferences & Connectivity',
        showStatusBadge: true,
        statusText: appBarStatusText,
        statusType: appBarStatusType,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await _loadInitialSettings();
          await _testBackendConnection();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // 1. Account & Organization Profile Card
            _buildAccountCard(user),

            const SizedBox(height: 20),

            // 2. Backend / API Live Connection Status & Demo Switch Card
            _buildSectionHeader('FastAPI Backend & API Connectivity'),
            const SizedBox(height: 8),
            _buildBackendConnectionCard(),

            const SizedBox(height: 20),

            // 3. API Base URL Configuration Card
            _buildSectionHeader('API Base URL Configuration'),
            const SizedBox(height: 8),
            _buildBackendUrlConfigCard(),

            const SizedBox(height: 20),

            // 4. SIEM & External Integrations (GitHub & Wazuh)
            _buildSectionHeader('SOC & SIEM Connector Integrations'),
            const SizedBox(height: 8),
            _buildExternalIntegrationsCard(),

            const SizedBox(height: 20),

            // 5. Security, Biometrics & Cryptography
            _buildSectionHeader('Authentication & Cryptography'),
            const SizedBox(height: 8),
            _buildSecuritySettingsCard(),

            const SizedBox(height: 20),

            // 7. Incident Notifications & Dispatch
            _buildSectionHeader('Notifications & Incident Dispatch'),
            const SizedBox(height: 8),
            _buildNotificationSettingsCard(),

            const SizedBox(height: 20),

            // 8. Theme & Display Mode
            _buildSectionHeader('Appearance & Theme'),
            const SizedBox(height: 8),
            _buildThemeCard(),

            const SizedBox(height: 20),

            // 9. About SecureGuard & Platform Specs
            _buildSectionHeader('Platform Information & Compliance'),
            const SizedBox(height: 8),
            _buildAboutCard(),

            const SizedBox(height: 28),

            // 10. Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _handleLogoutConfirmation,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.critical, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: AppColors.cardBorderRadius),
                ),
                icon: const Icon(Icons.logout_rounded, color: AppColors.critical, size: 20),
                label: const Text(
                  'Sign Out of Enterprise Session',
                  style: TextStyle(color: AppColors.critical, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // 1. Account / Profile Card
  Widget _buildAccountCard(dynamic user) {
    final String name = user?.name ?? 'Alex Vance';
    final String role = user?.role ?? 'Principal Security Analyst';
    final String email = user?.email ?? 'analyst@secureguard.enterprise';
    final String organization = user?.organization ?? 'Global Cybersecurity Ops';
    final String initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SGAvatar(
                initials: initials.isNotEmpty ? initials : 'SG',
                radius: 26,
                isOnline: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.business_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  organization,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const SGChip(
                label: 'MFA ENFORCED',
                variant: SGChipVariant.success,
                icon: Icons.shield_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Live Backend Connectivity Status Card
  Widget _buildBackendConnectionCard() {
    final bool? isReachable = _isBackendReachable;
    final bool isConnected = isReachable == true;
    final String statusLabel = isReachable == null
        ? (_isDemoMode ? 'OFFLINE (DEMO)' : 'NOT TESTED')
        : (isConnected ? 'CONNECTED' : 'DISCONNECTED');
    final Color statusColor = isConnected
        ? AppColors.success
        : (_isDemoMode ? AppColors.warning : AppColors.critical);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Health Probe Status Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Backend: ',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        Flexible(
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _connectionStatusText,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_isTestingConnection)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    isReachable != null ? '${_latencyMs}ms' : (_isDemoMode ? 'DEMO' : '--'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isConnected ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 12),
          // Target URL & Test Ping Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Target: ${_backendUrlController.text.trim()}',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _isTestingConnection ? null : _testBackendConnection,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text('Test Ping', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Real-Time WebSocket Stream Status
          Consumer(
            builder: (context, ref, _) {
              final wsStatusAsync = ref.watch(webSocketStatusStreamProvider);
              final wsStatus = wsStatusAsync.value ?? ref.watch(webSocketServiceProvider).currentStatus;

              final String wsLabel = _isDemoMode
                  ? 'OFFLINE (DEMO)'
                  : (wsStatus == WebSocketStatus.connected
                      ? 'LIVE'
                      : (wsStatus == WebSocketStatus.reconnecting ? 'RECONNECTING' : 'OFFLINE'));
              final StatusType wsType = _isDemoMode
                  ? StatusType.warning
                  : (wsStatus == WebSocketStatus.connected
                      ? StatusType.normal
                      : (wsStatus == WebSocketStatus.reconnecting ? StatusType.warning : StatusType.critical));

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stream_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Real-Time WebSocket:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SGStatusBadge(label: wsLabel, type: wsType),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 12),
          // Demo / Offline Mode Switch
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isDemoMode
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isDemoMode
                        ? AppColors.warning.withValues(alpha: 0.35)
                        : AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  _isDemoMode ? Icons.science_outlined : Icons.cloud_done_rounded,
                  color: _isDemoMode ? AppColors.warning : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Demo / Offline Mode',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        SGStatusBadge(
                          label: _isDemoMode ? 'DEMO ACTIVE' : 'LIVE API',
                          type: _isDemoMode ? StatusType.warning : StatusType.normal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isDemoMode
                          ? 'Operating with offline mock SOC telemetry'
                          : 'Connected to live FastAPI REST backend engine',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isDemoMode,
                activeThumbColor: AppColors.primary,
                onChanged: (val) async {
                  setState(() => _isDemoMode = val);
                  AppConfig.isDemoMode = val;
                  ref.read(isDemoModeProvider.notifier).state = val;
                  await _persistSettings();
                  if (!val) {
                    await _testBackendConnection();
                    ref.read(webSocketServiceProvider).connect();
                  } else {
                    await ref.read(webSocketServiceProvider).disconnect();
                  }
                  ref.invalidate(liveDashboardNotifierProvider);
                  ref.invalidate(liveAlertsNotifierProvider);
                  ref.invalidate(repositoriesDataProvider);
                  ref.invalidate(scansListProvider);
                  ref.invalidate(findingsListProvider);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              val ? Icons.science_outlined : Icons.cloud_done_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                val
                                    ? 'Offline Demo Simulation Mode Enabled.'
                                    : 'Live FastAPI Backend Mode Enabled.',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: val ? AppColors.warning : AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. API Base URL Config Card
  Widget _buildBackendUrlConfigCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FastAPI REST Engine URL',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Target host URL for live vulnerability scanning, Semgrep SAST telemetry, and SOC SIEM logs.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.3),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _backendUrlController,
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              filled: true,
              fillColor: AppColors.card,
              hintText: 'http://10.0.2.2:8000',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
              prefixIcon: Icon(Icons.link_rounded, color: AppColors.textSecondary, size: 18),
              suffixIcon: IconButton(
                icon: const Icon(Icons.save_rounded, color: AppColors.primary, size: 20),
                onPressed: _saveBackendUrl,
                tooltip: 'Save URL',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildPresetChip('Emulator (10.0.2.2:8000)', AppConfig.emulatorApiBaseUrl),
              _buildPresetChip('Localhost (127.0.0.1:8000)', AppConfig.localhostApiBaseUrl),
              _buildPresetChip('Cloud API (api.secureguard.enterprise)', AppConfig.productionApiBaseUrl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String url) {
    final bool isSelected = _backendUrlController.text.trim() == url;
    return InkWell(
      onTap: () {
        setState(() {
          _backendUrlController.text = url;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 4. SIEM & External Integrations Card (GitHub & Wazuh)
  Widget _buildExternalIntegrationsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // GitHub Integration Tile
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24292F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF444C56)),
                  ),
                  child: const Icon(Icons.code_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'GitHub Enterprise App',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const SGStatusBadge(label: 'SYNCED', type: StatusType.normal),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Org: SecureGuard-Enterprise • 8 Repos Active',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _githubConnected,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    setState(() => _githubConnected = val);
                    await _persistSettings();
                  },
                ),
              ],
            ),
          ),
          Divider(color: AppColors.cardBorder, height: 1),
          // Wazuh SIEM Tile
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Wazuh SOC SIEM Node',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const SGStatusBadge(label: 'ONLINE', type: StatusType.normal),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manager: 192.168.1.100:1514 • 142 Agents',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _wazuhConnected,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) async {
                    setState(() => _wazuhConnected = val);
                    await _persistSettings();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Security & Cryptography Card
  Widget _buildSecuritySettingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            title: 'Biometric Fingerprint / Face Unlock',
            subtitle: 'Require Android hardware biometric verification to unlock platform',
            value: _biometricsEnabled,
            onChanged: _handleBiometricToggle,
          ),
          Divider(color: AppColors.cardBorder, height: 1),
          _buildToggleRow(
            title: 'Encrypted Local Hive Cache (AES-256)',
            subtitle: 'Hardware Keystore-backed master encryption keys',
            value: _localEncryption,
            onChanged: (val) async {
              setState(() => _localEncryption = val);
              await _persistSettings();
            },
          ),
          Divider(color: AppColors.cardBorder, height: 1),
          InkWell(
            onTap: () async {
              await ref.read(settingsRepositoryProvider).clearLocalCache();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Local cache purged successfully.'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Clear Decrypted Local Cache', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.critical)),
                        const SizedBox(height: 2),
                        Text('Purge all offline cached findings, repository trees, and session data', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.delete_sweep_rounded, color: AppColors.critical, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 7. Notification Settings Card
  Widget _buildNotificationSettingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildToggleRow(
            title: 'Real-time Push Security Alerts',
            subtitle: 'Receive push alerts for newly discovered high and critical CVEs',
            value: _pushNotifications,
            onChanged: (val) async {
              setState(() => _pushNotifications = val);
              await _persistSettings();
            },
          ),
          Divider(color: AppColors.cardBorder, height: 1),
          _buildToggleRow(
            title: 'Critical Severity Only (CVSS >= 9.0)',
            subtitle: 'Filter push notifications to critical zero-day vulnerabilities only',
            value: _criticalOnly,
            onChanged: (val) async {
              setState(() => _criticalOnly = val);
              await _persistSettings();
            },
          ),
          Divider(color: AppColors.cardBorder, height: 1),
          _buildToggleRow(
            title: 'Daily Executive Security Digest',
            subtitle: 'Receive a daily 08:00 AM summary of vulnerability posture',
            value: _dailyDigest,
            onChanged: (val) async {
              setState(() => _dailyDigest = val);
              await _persistSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // 8. Theme Card
  Widget _buildThemeCard() {
    final currentThemeMode = ref.watch(themeModeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Theme & Appearance',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Select your preferred workspace visual contrast mode',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildThemeOptionButton(
                  title: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.dark,
                  onTap: () {
                    setState(() => _themeMode = 'dark');
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                    _persistSettings();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOptionButton(
                  title: 'Light',
                  icon: Icons.light_mode_rounded,
                  isSelected: currentThemeMode == ThemeMode.light,
                  onTap: () {
                    setState(() => _themeMode = 'light');
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                    _persistSettings();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildThemeOptionButton(
                  title: 'System',
                  icon: Icons.brightness_auto_rounded,
                  isSelected: currentThemeMode == ThemeMode.system,
                  onTap: () {
                    setState(() => _themeMode = 'system');
                    ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                    _persistSettings();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Theme Palette:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              _buildColorDot(AppColors.primary),
              const SizedBox(width: 4),
              _buildColorDot(AppColors.surface),
              const SizedBox(width: 4),
              _buildColorDot(AppColors.success),
              const SizedBox(width: 4),
              _buildColorDot(AppColors.critical),
              const SizedBox(width: 4),
              _buildColorDot(AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOptionButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
    );
  }

  // 9. About SecureGuard & Platform Specs Card
  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.appName} Mobile Enterprise',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      AppStrings.appTagline,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  AppStrings.appVersion,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Enterprise security orchestration platform with Semgrep SAST continuous scanning, GitHub App CI/CD integration, and Wazuh SOC SIEM event streaming.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Security Standard', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text('FIPS 140-3 â€¢ SOC 2 Type II', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}