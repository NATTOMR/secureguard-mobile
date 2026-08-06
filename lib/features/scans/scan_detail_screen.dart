import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

class ScanDetailScreen extends StatelessWidget {
  final String scanId;

  const ScanDetailScreen({
    super.key,
    required this.scanId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SGAppBar(
        title: 'Scan Execution: $scanId',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SGCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SAST Static Analysis Engine',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SGChip(label: 'COMPLETED', variant: SGChipVariant.success),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Target: auth-gateway-service (main branch)',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      SGChip(label: '8 Findings', variant: SGChipVariant.critical),
                      SizedBox(width: 8),
                      SGChip(label: 'Duration: 12m 14s', variant: SGChipVariant.info),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            const Text(
              'Scan Execution Output Logs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF090D16),
                borderRadius: AppColors.cardBorderRadius,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const SelectableText(
                '''[14:02:11] [INFO] Initializing Semgrep & SonarQube rulesets...
[14:02:15] [INFO] Parsing 1,420 source files...
[14:02:30] [WARN] Found potential hardcoded token in config/auth.go:L42
[14:03:02] [ALERT] High Severity: CVE-2024-3094 matched in base layer!
[14:04:10] [SUCCESS] Scan complete. Artifact report generated.''',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF38BDF8),
                  height: 1.5,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
