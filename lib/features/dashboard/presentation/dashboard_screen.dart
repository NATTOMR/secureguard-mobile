import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/app_providers.dart';
import '../domain/dashboard_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final isDemo = ref.watch(isDemoModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SGAppBar(
        title: AppStrings.appName,
        subtitle: AppStrings.appTagline,
        showStatusBadge: true,
        statusText: isDemo ? 'DEMO MODE' : 'SOC ONLINE',
        statusType: isDemo ? StatusType.warning : StatusType.normal,
      ),
      body: dashboardAsync.when(
        data: (data) => _buildDashboardContent(context, ref, data),
        loading: () => const Center(
          child: SGLoading(message: 'Connecting to SecureGuard SOC engine...'),
        ),
        error: (err, stack) => SGErrorView(
          message: 'Unable to load dashboard telemetry: $err',
          onRetry: () => ref.read(liveDashboardNotifierProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, WidgetRef ref, DashboardModel data) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => ref.read(liveDashboardNotifierProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Security Posture Header Banner
            _buildPostureBanner(context, data),

            const SizedBox(height: 16),

            // 2. Metrics Grid (Critical, High, Medium, Low, Repos, Alerts, Scans)
            _buildMetricsGrid(context, data),

            const SizedBox(height: 20),

            // 3. Quick Actions
            _buildQuickActions(context),

            const SizedBox(height: 24),

            // 4. Vulnerability Distribution Chart
            _buildVulnerabilityChart(context, data),

            const SizedBox(height: 24),

            // 5. Recent Security Events (Wazuh / SOC / GitHub)
            _buildRecentEvents(context, data),

            const SizedBox(height: 24),

            // 6. Recent Scans (Semgrep SAST / Secrets / Container)
            _buildRecentScans(context, data),

            const SizedBox(height: 24),

            // 7. System Infrastructure Health
            _buildInfrastructureStatus(context, data),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPostureBanner(BuildContext context, DashboardModel data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppColors.cardBorderRadius,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        gradient: const LinearGradient(
          colors: [Color(0x262563EB), Color(0x0A0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Security Posture',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${data.postureScore}/100 • ${data.postureStatus}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Continuous Semgrep SAST & Wazuh SOC monitoring active across all endpoints.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildMetricsGrid(BuildContext context, DashboardModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Telemetry Overview',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SGStatisticCard(
                title: 'Critical',
                value: data.criticalCount.toString(),
                icon: Icons.dangerous_rounded,
                accentColor: AppColors.critical,
                onTap: () => context.go(AppRouter.findings),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SGStatisticCard(
                title: 'High',
                value: data.highCount.toString(),
                icon: Icons.warning_rounded,
                accentColor: AppColors.high,
                onTap: () => context.go(AppRouter.findings),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SGStatisticCard(
                title: 'Medium',
                value: data.mediumCount.toString(),
                icon: Icons.report_problem_rounded,
                accentColor: AppColors.warning,
                onTap: () => context.go(AppRouter.findings),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SGStatisticCard(
                title: 'Low',
                value: data.lowCount.toString(),
                icon: Icons.info_rounded,
                accentColor: AppColors.low,
                onTap: () => context.go(AppRouter.findings),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SGStatisticCard(
                title: 'Repositories',
                value: data.totalRepositories.toString(),
                icon: Icons.folder_special_rounded,
                accentColor: AppColors.primary,
                onTap: () => context.go(AppRouter.repositories),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SGStatisticCard(
                title: 'Active Alerts',
                value: data.activeAlertsCount.toString(),
                icon: Icons.notifications_active_rounded,
                accentColor: AppColors.critical,
                onTap: () => context.go(AppRouter.alerts),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Security Actions',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              QuickActionCard(
                title: 'Trigger Scan',
                subtitle: 'SAST & Secrets',
                icon: Icons.radar_rounded,
                accentColor: AppColors.primary,
                onTap: () => context.push(AppRouter.scans),
              ),
              const SizedBox(width: 12),
              QuickActionCard(
                title: 'Ask SecureGuard AI',
                subtitle: 'Remediation Chat',
                icon: Icons.auto_awesome_rounded,
                accentColor: const Color(0xFF8B5CF6),
                onTap: () => context.go(AppRouter.aiAssistant),
              ),
              const SizedBox(width: 12),
              QuickActionCard(
                title: 'Alert Triage',
                subtitle: 'SOC Incidents',
                icon: Icons.shield_outlined,
                accentColor: AppColors.critical,
                onTap: () => context.go(AppRouter.alerts),
              ),
              const SizedBox(width: 12),
              QuickActionCard(
                title: 'Export Report',
                subtitle: 'PDF & Compliance',
                icon: Icons.description_rounded,
                accentColor: AppColors.success,
                onTap: () => context.push(AppRouter.reports),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVulnerabilityChart(BuildContext context, DashboardModel data) {
    return ChartCard(
      title: 'Vulnerability Severity Distribution',
      subtitle: '${data.totalVulnerabilities} total identified findings',
      criticalCount: data.criticalCount,
      highCount: data.highCount,
      mediumCount: data.mediumCount,
      lowCount: data.lowCount,
    );
  }

  Widget _buildRecentEvents(BuildContext context, DashboardModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Security Events',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => context.go(AppRouter.alerts),
              child: const Text('View All Alerts', style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.recentEvents.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final evt = data.recentEvents[index];
            final Color sevColor = _getSeverityColor(evt.severity);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: sevColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evt.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                evt.source,
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTime(evt.timestamp),
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentScans(BuildContext context, DashboardModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Scans',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => context.push(AppRouter.scans),
              child: const Text('All Scans', style: TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.recentScans.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final scan = data.recentScans[index];
            final bool isPassed = scan.status.toLowerCase() == 'passed';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(
                    isPassed ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                    color: isPassed ? AppColors.success : AppColors.critical,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.target,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${scan.scanType} • ${scan.duration} • ${scan.findingsCount} findings',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(scan.timestamp),
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfrastructureStatus(BuildContext context, DashboardModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOC Connector Infrastructure Health',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.systemStatuses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final sys = data.systemStatuses[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      sys.name,
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    '${sys.latencyMs}ms',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppColors.critical;
      case 'high':
        return AppColors.high;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.low;
      default:
        return AppColors.info;
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
