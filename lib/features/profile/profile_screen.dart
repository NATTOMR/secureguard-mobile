import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authStateProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: 'Analyst Profile',
        showBackButton: false,
        showStatusBadge: true,
        statusText: 'MFA ACTIVE',
        statusType: StatusType.normal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Avatar & Title Card
            SGCard(
              child: Column(
                children: [
                  const SGAvatar(initials: 'AV', radius: 42),
                  const SizedBox(height: 16),
                  Text(
                    userState?.name ?? 'Alex Vance',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userState?.email ?? 'analyst@securepulse.enterprise',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SGChip(label: 'Lead Security Architect', variant: SGChipVariant.info),
                      SizedBox(width: 8),
                      SGChip(label: 'ADMIN ACCESS', variant: SGChipVariant.success),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Credentials & Security Keys Card
            SGCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Security Credentials & MFA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileRow('Hardware YubiKey MFA', 'ENFORCED', Icons.vpn_key_rounded),
                  Divider(color: AppColors.cardBorder),
                  _buildProfileRow('Active Session Token', 'EXPIRES IN 8H', Icons.timer_rounded),
                  Divider(color: AppColors.cardBorder),
                  _buildProfileRow('API Security Scope', 'READ/WRITE/TRIAGE', Icons.admin_panel_settings_rounded),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Logout Button
            SGButton(
              label: 'Sign Out of SecurePulse Platform',
              variant: SGButtonVariant.danger,
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
                context.go(AppRouter.login);
              },
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          ),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
