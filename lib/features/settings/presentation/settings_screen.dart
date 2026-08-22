import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _backendUrlController;
  bool _biometricsEnabled = true;
  bool _pushNotifications = true;
  bool _criticalOnly = false;
  bool _localEncryption = true;

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController(text: AppConfig.apiBaseUrl);
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    super.dispose();
  }

  void _saveBackendUrl() {
    final newUrl = _backendUrlController.text.trim();
    if (newUrl.isNotEmpty) {
      AppConfig.apiBaseUrl = newUrl;
      ref.read(apiClientProvider).updateBaseUrl(newUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FastAPI Backend URL updated to: $newUrl'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: AppStrings.navSettings,
        subtitle: 'Enterprise Platform Preferences & Connectivity',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Account & Organization Profile Card
            _buildAccountCard(user),

            const SizedBox(height: 20),

            // 2. FastAPI Backend Connectivity Section
            _buildSectionHeader('Backend Connectivity (FastAPI Engine)'),
            const SizedBox(height: 8),
            _buildBackendUrlConfig(),

            const SizedBox(height: 20),

            // 3. Authentication & Security Section
            _buildSectionHeader('Authentication & Cryptography'),
            const SizedBox(height: 8),
            _buildSecuritySettings(),

            const SizedBox(height: 20),

            // 4. Notifications & Incident Dispatch Section
            _buildSectionHeader('Notifications & Incident Alerts'),
            const SizedBox(height: 8),
            _buildNotificationSettings(),

            const SizedBox(height: 20),

            // 5. Theme & Appearance
            _buildSectionHeader('Appearance & Theme'),
            const SizedBox(height: 8),
            _buildThemeSettings(),

            const SizedBox(height: 20),

            // 6. About SecureGuard
            _buildSectionHeader('Platform Information'),
            const SizedBox(height: 8),
            _buildAboutCard(),

            const SizedBox(height: 24),

            // 7. Logout Button
            SGButton(
              label: 'Sign Out of Enterprise Session',
              variant: SGButtonVariant.outline,
              icon: const Icon(Icons.logout_rounded, color: AppColors.critical, size: 20),
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppRouter.login);
                }
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
    );
  }

  Widget _buildAccountCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Alex Vance',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.role ?? 'Principal Security Analyst',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.organization ?? 'Global Cybersecurity Ops',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Text('MFA ON', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendUrlConfig() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FastAPI REST Base URL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Points to your SecureGuard backend instance (e.g. http://10.0.2.2:8000 on Android Emulator).',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _backendUrlController,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveBackendUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Biometric Fingerprint / Face Unlock', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            subtitle: const Text('Use Android biometric hardware for secure local authentication', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            value: _biometricsEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _biometricsEnabled = val),
          ),
          const Divider(color: AppColors.cardBorder, height: 1),
          SwitchListTile(
            title: const Text('Encrypted Local Hive Storage (AES-256)', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            subtitle: const Text('Encrypt cached telemetry with Android KeyStore-backed secrets', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            value: _localEncryption,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _localEncryption = val),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Real-time Push Alerts', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            subtitle: const Text('Receive immediate notifications for newly detected vulnerabilities', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            value: _pushNotifications,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          const Divider(color: AppColors.cardBorder, height: 1),
          SwitchListTile(
            title: const Text('Critical Severity Alerts Only', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            subtitle: const Text('Filter push notifications to CVSS >= 9.0 incidents', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            value: _criticalOnly,
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _criticalOnly = val),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.dark_mode_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enterprise Dark Theme', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text('Optimized for high-contrast SOC monitoring environments', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text('Enforced', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                '${AppStrings.appName} Mobile',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Spacer(),
              Text(
                AppStrings.appVersion,
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Official mobile interface for the SecureGuard Enterprise Security Platform. Powered by FastAPI backend engine with Semgrep SAST, GitHub App, and SOC SIEM connectors (Wazuh, Splunk, Microsoft Sentinel, Elastic).',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
