import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/widgets.dart';

class FindingDetailScreen extends StatelessWidget {
  final String findingId;

  const FindingDetailScreen({
    super.key,
    required this.findingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SGAppBar(
        title: 'Finding: $findingId',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'CVE-2024-3094',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.critical),
                      ),
                      SGChip(label: 'CRITICAL 10.0', variant: SGChipVariant.critical),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'XZ Utils Backdoor Vulnerability in SSHD Pipeline',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Malicious obfuscated code introduced in XZ Utils release builds allows remote attacker to bypass SSH authentication and execute arbitrary code.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Repo: auth-gateway-service', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text('File: base-image.Dockerfile:L14', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            const Text(
              'Remediation Steps & Fix Guide',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            SGCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '1. Upgrade xz-utils package to version >= 5.6.2.\n'
                    '2. Rebuild docker base layers and purge cached images in CI runner.\n'
                    '3. Rotate all SSH host keys deployed to production gateways.',
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            SGButton(
              label: 'Ask AI Copilot for Fix Code',
              variant: SGButtonVariant.primary,
              icon: const Icon(Icons.psychology_rounded, color: Colors.white),
              onPressed: () => context.push(AppRouter.aiCopilot),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
