import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = true;
  bool _pushNotifications = true;
  bool _offlineCaching = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: 'Security Settings',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SGCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Security & Authentication',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Require Biometric Lock', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  subtitle: const Text('Require Face ID / Fingerprint on app open', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  value: _biometricEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _biometricEnabled = val),
                ),
                const Divider(color: AppColors.cardBorder),
                SwitchListTile(
                  title: const Text('Push Threat Notifications', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  subtitle: const Text('Receive real-time SIEM alerts for Critical CVEs', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  value: _pushNotifications,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(color: AppColors.cardBorder),
                SwitchListTile(
                  title: const Text('Encrypted Offline Cache', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  subtitle: const Text('Store repository metadata securely using AES-256', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  value: _offlineCaching,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _offlineCaching = val),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          const SGCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About SecureGuard Mobile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                SizedBox(height: 12),
                Text('Platform Version: ${AppStrings.appVersion}', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                SizedBox(height: 4),
                Text('Security Standard: FIPS 140-3 Compliant', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }
}
