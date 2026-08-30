import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';

class ScansScreen extends ConsumerWidget {
  const ScansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scansAsync = ref.watch(scansListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SGAppBar(
        title: AppStrings.recentScans,
        showBackButton: false,
        showStatusBadge: true,
        statusText: 'SCAN ENGINE ACTIVE',
        statusType: StatusType.normal,
        actions: [
          IconButton(
            icon: Icon(Icons.add_task_rounded, color: AppColors.primary),
            onPressed: () => _showStartScanDialog(context),
          ),
        ],
      ),
      body: scansAsync.when(
        loading: () => SGLoading(message: 'Loading Active Scan Pipeline...'),
        error: (err, st) => SGErrorView(
          errorMessage: err.toString(),
          onRetry: () => ref.refresh(scansListProvider),
        ),
        data: (scans) {
          if (scans.isEmpty) {
            return SGEmptyState(
              title: 'No Active Scans',
              description: 'Start a new SAST or Container scan engine job.',
              icon: Icons.radar_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];
              return _buildScanTile(context, scan, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showStartScanDialog(context),
        icon: Icon(Icons.play_arrow_rounded),
        label: Text('Start New Scan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildScanTile(BuildContext context, ScanModel scan, int index) {
    Color statusColor;
    String statusLabel;
    IconData typeIcon;

    switch (scan.status) {
      case ScanStatus.completed:
        statusColor = AppColors.success;
        statusLabel = 'COMPLETED';
        break;
      case ScanStatus.inProgress:
        statusColor = AppColors.warning;
        statusLabel = 'RUNNING';
        break;
      case ScanStatus.failed:
        statusColor = AppColors.critical;
        statusLabel = 'FAILED';
        break;
    }

    switch (scan.type) {
      case ScanType.sast:
        typeIcon = Icons.code_rounded;
        break;
      case ScanType.dast:
        typeIcon = Icons.public_rounded;
        break;
      case ScanType.dependency:
        typeIcon = Icons.account_tree_rounded;
        break;
      case ScanType.container:
        typeIcon = Icons.view_in_ar_rounded;
        break;
      case ScanType.secret:
        typeIcon = Icons.vpn_key_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SGCard(
        onTap: () => context.push('/scans/${scan.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Icon(typeIcon, color: statusColor, size: 22),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.targetName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Trigger: ${scan.triggerBy}',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                SGStatusBadge(
                  label: statusLabel,
                  type: scan.status == ScanStatus.completed
                      ? StatusType.normal
                      : scan.status == ScanStatus.inProgress
                          ? StatusType.warning
                          : StatusType.critical,
                ),
              ],
            ),

            SizedBox(height: 14),
            Divider(color: AppColors.cardBorder),
            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.bug_report_outlined, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 4),
                    Text(
                      '${scan.findingsCount} Findings Detected',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  AppFormatters.formatShortDate(scan.startedAt),
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms),
    );
  }

  void _showStartScanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Configure Security Scan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SGTextField(
                label: 'Target Repository or Container Image',
                hintText: 'e.g. secureguard-mobile:latest',
              ),
              SizedBox(height: 20),
              SGButton(
                label: 'Launch Scan Job Now',
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Scan job dispatched to agent worker pool.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
