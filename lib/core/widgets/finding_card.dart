import 'package:flutter/material.dart';
import '../../models/finding_model.dart';
import '../constants/app_colors.dart';
import '../utils/formatters.dart';
import 'dashboard_card.dart';
import 'sg_chip.dart';

class FindingCard extends StatelessWidget {
  final FindingModel finding;
  final VoidCallback onTap;

  const FindingCard({
    super.key,
    required this.finding,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    SGChipVariant chipVariant;
    switch (finding.severity) {
      case SeverityLevel.critical:
        chipVariant = SGChipVariant.critical;
        break;
      case SeverityLevel.high:
        chipVariant = SGChipVariant.high;
        break;
      case SeverityLevel.medium:
        chipVariant = SGChipVariant.medium;
        break;
      case SeverityLevel.low:
        chipVariant = SGChipVariant.low;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: DashboardCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14.0),
        borderColor: finding.severity == SeverityLevel.critical ? AppColors.critical.withValues(alpha: 0.4) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  finding.cveId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SGChip(label: finding.severity.name, variant: chipVariant),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              finding.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.source_rounded, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    finding.repositoryName,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.radar_rounded, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Semgrep Engine',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                Text(
                  AppFormatters.formatShortDate(finding.detectedAt),
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
