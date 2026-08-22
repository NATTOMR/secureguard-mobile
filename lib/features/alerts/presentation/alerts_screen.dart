import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/app_providers.dart';
import '../domain/alert_model.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String _selectedSeverity = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: AppStrings.navAlerts,
        subtitle: 'SIEM, SOC & SAST Live Incident Stream',
        showStatusBadge: true,
        statusText: 'FEED ACTIVE',
        statusType: StatusType.normal,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SGSearchBar(
              hintText: 'Search alerts, sources, or CVEs...',
              onChanged: (q) {
                setState(() {
                  _searchQuery = q;
                });
              },
            ),
          ),

          // Severity Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildSeverityChip('All', null),
                const SizedBox(width: 8),
                _buildSeverityChip('Critical', AppColors.critical),
                const SizedBox(width: 8),
                _buildSeverityChip('High', AppColors.high),
                const SizedBox(width: 8),
                _buildSeverityChip('Medium', AppColors.warning),
                const SizedBox(width: 8),
                _buildSeverityChip('Low', AppColors.low),
                const SizedBox(width: 8),
                _buildSeverityChip('Info', AppColors.info),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Alerts List
          Expanded(
            child: alertsAsync.when(
              data: (alerts) {
                final filtered = alerts.where((alert) {
                  final matchesSearch = alert.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      alert.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      alert.source.toLowerCase().contains(_searchQuery.toLowerCase());

                  if (!matchesSearch) return false;

                  if (_selectedSeverity == 'All') return true;
                  if (_selectedSeverity == 'Info') return alert.severity == AlertSeverity.informational;
                  return alert.severity.name.toLowerCase() == _selectedSeverity.toLowerCase();
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: SGEmptyState(
                      title: 'No Security Alerts',
                      subtitle: 'No incidents match your current search and severity filters.',
                      icon: Icons.shield_outlined,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async => ref.invalidate(alertsDataProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alert = filtered[index];
                      return _buildAlertCard(context, alert);
                    },
                  ),
                );
              },
              loading: () => const Center(child: SGLoading(message: 'Querying SOC alert stream...')),
              error: (err, _) => SGErrorView(
                message: 'Failed to fetch alerts: $err',
                onRetry: () => ref.invalidate(alertsDataProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String label, Color? accentColor) {
    final isSelected = _selectedSeverity == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: accentColor ?? AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? (accentColor ?? AppColors.primary) : AppColors.cardBorder,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedSeverity = label;
          });
        }
      },
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertModel alert) {
    final Color sevColor = _getSeverityColor(alert.severity);

    return InkWell(
      onTap: () {
        context.push('${AppRouter.alerts}/${alert.id}');
      },
      borderRadius: AppColors.cardBorderRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppColors.cardBorderRadius,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Severity Badge + Source + Timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sevColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sevColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    alert.severity.name.toUpperCase(),
                    style: TextStyle(
                      color: sevColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    alert.source,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatAlertTime(alert.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              alert.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 6),

            // Description
            Text(
              alert.description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 10),

            // Bottom Status Row
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: alert.status == AlertStatus.active
                        ? AppColors.critical
                        : alert.status == AlertStatus.investigating
                            ? AppColors.warning
                            : AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Status: ${alert.status.name.toUpperCase()}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                ),
                const Spacer(),
                const Text(
                  'View Triage Details →',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.critical;
      case AlertSeverity.high:
        return AppColors.high;
      case AlertSeverity.medium:
        return AppColors.warning;
      case AlertSeverity.low:
        return AppColors.low;
      case AlertSeverity.informational:
        return AppColors.info;
    }
  }

  String _formatAlertTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
