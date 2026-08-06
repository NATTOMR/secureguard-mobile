import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';

class SocScreen extends ConsumerWidget {
  const SocScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socAlertsAsync = ref.watch(socAlertsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: AppStrings.socConsole,
        showBackButton: false,
        showStatusBadge: true,
        statusText: 'SIEM STREAMING',
        statusType: StatusType.warning,
      ),
      body: socAlertsAsync.when(
        loading: () => const SGLoading(message: 'Connecting to Realtime SIEM Feed...'),
        error: (err, st) => SGErrorView(
          errorMessage: err.toString(),
          onRetry: () => ref.refresh(socAlertsListProvider),
        ),
        data: (alerts) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.refresh(socAlertsListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertCard(context, alert, index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, SocAlertModel alert, int index) {
    SGChipVariant chipVariant;
    switch (alert.severity) {
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SGCard(
        borderColor: alert.severity == SeverityLevel.critical ? AppColors.critical.withValues(alpha: 0.5) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: alert.severity == SeverityLevel.critical ? AppColors.critical : AppColors.warning,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: alert.severity == SeverityLevel.critical ? AppColors.critical : AppColors.warning,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alert.eventType,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SGChip(label: alert.severity.name, variant: chipVariant),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              alert.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lan_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('Source IP: ${alert.sourceIp}', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.dns_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text('Target Host: ${alert.targetHost}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormatters.formatShortDate(alert.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shield_rounded, size: 16),
                  label: Text(alert.isAcknowledged ? 'ACKNOWLEDGED' : 'ACK & TRIAGE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alert.isAcknowledged ? AppColors.surface : AppColors.primary,
                    foregroundColor: alert.isAcknowledged ? AppColors.textMuted : Colors.white,
                    minimumSize: const Size(120, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Triage action executed for ${alert.id}')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms),
    );
  }
}
