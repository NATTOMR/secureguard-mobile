import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

class RepositoryDetailScreen extends StatelessWidget {
  final String repositoryId;

  const RepositoryDetailScreen({
    super.key,
    required this.repositoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SGAppBar(
        title: 'Repository: $repositoryId',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SGCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.folder_special_rounded, color: AppColors.primary, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'secureguard-backend-api',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                      SGChip(label: 'GRADE A', variant: SGChipVariant.success),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Main enterprise API gateway handling authentication, role RBAC enforcement, and vulnerability database integrations.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Default Branch: main', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                      Text('Language: Go / Python', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            const Text(
              'Security Policy & SAST Checks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            SGCard(
              child: Column(
                children: [
                  _buildPolicyRow('Branch Protection Enforced', true),
                  const Divider(color: AppColors.cardBorder),
                  _buildPolicyRow('Secret Scanning Automated', true),
                  const Divider(color: AppColors.cardBorder),
                  _buildPolicyRow('Dependency Bot Auto-PRs', true),
                  const Divider(color: AppColors.cardBorder),
                  _buildPolicyRow('Container Signature Verification', false),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            SGButton(
              label: 'Trigger Immediate SAST Scan',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Triggered SAST scan workflow on main branch.')),
                );
              },
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyRow(String label, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          SGChip(
            label: isEnabled ? 'PASSED' : 'ACTION REQ',
            variant: isEnabled ? SGChipVariant.success : SGChipVariant.warning,
          ),
        ],
      ),
    );
  }
}
