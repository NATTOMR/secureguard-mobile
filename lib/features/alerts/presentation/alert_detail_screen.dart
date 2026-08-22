import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/app_providers.dart';
import '../domain/alert_model.dart';

class AlertDetailScreen extends ConsumerWidget {
  final String alertId;

  const AlertDetailScreen({super.key, required this.alertId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: 'Incident Triage',
        showBackButton: true,
        showStatusBadge: true,
        statusText: 'SOC DISPATCH',
        statusType: StatusType.critical,
      ),
      body: alertsAsync.when(
        data: (alerts) {
          final alert = alerts.firstWhere(
            (a) => a.id == alertId,
            orElse: () => alerts.first,
          );

          final Color sevColor = alert.severity == AlertSeverity.critical
              ? AppColors.critical
              : alert.severity == AlertSeverity.high
                  ? AppColors.high
                  : alert.severity == AlertSeverity.medium
                      ? AppColors.warning
                      : AppColors.low;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppColors.cardBorderRadius,
                    border: Border.all(color: sevColor.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sevColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              alert.severity.name.toUpperCase(),
                              style: TextStyle(color: sevColor, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Source: ${alert.source}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Text(
                            'Status: ${alert.status.name.toUpperCase()}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        alert.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        alert.description,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Remediation Recommendation Card
                if (alert.remediationRecommendation != null) ...[
                  const Text(
                    'Recommended Remediation Protocol',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppColors.cardBorderRadius,
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security_update_good_rounded, color: AppColors.success, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            alert.remediationRecommendation!,
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Action Buttons
                SGButton(
                  label: 'Remediate with SecureGuard AI',
                  icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                  onPressed: () {
                    context.go(AppRouter.aiAssistant);
                  },
                ),

                const SizedBox(height: 12),

                SGButton(
                  label: 'Mark Incident Investigated',
                  variant: SGButtonVariant.outline,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incident status updated to Investigating.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    context.pop();
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: SGLoading(message: 'Loading alert triage data...')),
        error: (err, _) => SGErrorView(message: 'Failed to load alert: $err'),
      ),
    );
  }
}
