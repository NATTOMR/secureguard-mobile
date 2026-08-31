import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'analyst@secureguard.enterprise');
  final _passwordController = TextEditingController(text: 'EnterprisePass123!');
  bool _rememberMe = true;
  final _biometricService = BiometricService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLoginSuccess() {
    ref.invalidate(liveDashboardNotifierProvider);
    ref.invalidate(liveAlertsNotifierProvider);
    ref.invalidate(repositoriesDataProvider);
    ref.invalidate(scansListProvider);
    ref.invalidate(findingsListProvider);
    ref.invalidate(appSettingsProvider);
    if (mounted) {
      context.go(AppRouter.dashboard);
    }
  }

  Future<void> _handleEmailLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(authStateProvider.notifier).loginWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            );
        _handleLoginSuccess();
      } catch (e) {
        if (mounted) {
          final errorMessage = e.toString().replaceAll('ApiException: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Authentication Failed: $errorMessage',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.critical,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Use Demo Mode',
                textColor: Colors.white,
                onPressed: () {
                  _handleOfflineLogin();
                },
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleGithubLogin() async {
    try {
      await ref.read(authStateProvider.notifier).loginWithGithub();
      _handleLoginSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GitHub Authentication failed: $e'),
            backgroundColor: AppColors.critical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleOfflineLogin() async {
    AppConfig.isDemoMode = true;
    ref.read(isDemoModeProvider.notifier).state = true;
    await ref.read(authStateProvider.notifier).loginOffline();
    _handleLoginSuccess();
  }

  Future<void> _handleBiometricAuth() async {
    final success = await _biometricService.authenticate();
    if (success) {
      await _handleOfflineLogin();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication bypassed for demo environment.'),
            backgroundColor: AppColors.primary,
          ),
        );
        _handleOfflineLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Top Header Brand Logo
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SecureGuard',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const Text(
                          'ENTERPRISE SECURITY PLATFORM',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 36),

                Text(
                  AppStrings.loginTitle,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 8),

                Text(
                  AppStrings.loginSubtitle,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // GitHub SSO Button
                SGButton(
                  label: AppStrings.githubLogin,
                  variant: SGButtonVariant.github,
                  isLoading: isLoading,
                  icon: const Icon(Icons.code_rounded, color: Colors.white, size: 22),
                  onPressed: _handleGithubLogin,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.cardBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider(color: AppColors.cardBorder)),
                  ],
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 20),

                // Corporate Email Input
                SGTextField(
                  label: 'Corporate Email',
                  hintText: 'analyst@company.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 18),

                // Password Input
                SGTextField(
                  label: 'Password',
                  hintText: '••••••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 12),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            side: BorderSide(color: AppColors.cardBorder, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.rememberMe,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset instructions dispatched.')),
                        );
                      },
                      child: const Text(
                        AppStrings.forgotPassword,
                        style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 550.ms),

                const SizedBox(height: 24),

                // Submit Button
                SGButton(
                  label: AppStrings.emailLogin,
                  isLoading: isLoading,
                  onPressed: _handleEmailLogin,
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                // Offline & Biometric Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: SGButton(
                        label: AppStrings.offlineLogin,
                        variant: SGButtonVariant.outline,
                        height: 48,
                        onPressed: _handleOfflineLogin,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _handleBiometricAuth,
                      borderRadius: AppColors.cardBorderRadius,
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppColors.cardBorderRadius,
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 26),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 650.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
