import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/app_providers.dart';

class RepositoryDetailScreen extends ConsumerWidget {
  final String repositoryId;

  const RepositoryDetailScreen({super.key, required this.repositoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(repositoriesDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SGAppBar(
        title: 'Repository Security',
        showBackButton: true,
        showStatusBadge: true,
        statusText: 'SCAN READY',
        statusType: StatusType.normal,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: () => ref.invalidate(repositoriesDataProvider),
          ),
        ],
      ),
      body: reposAsync.when(
        data: (repos) {
          final repo = repos.firstWhere(
            (r) => r.id == repositoryId,
            orElse: () => repos.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppColors.cardBorderRadius,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.folder_special_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  repo.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Owner: ${repo.owner} • Branch: ${repo.branch}',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: AppColors.cardBorder, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('Security Status', repo.securityStatus, AppColors.primary),
                          _buildStatItem('Grade', repo.securityHealthScore, AppColors.success),
                          _buildStatItem('Language', repo.primaryLanguage, AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Findings Breakdown
                Text(
                  'Identified Security Vulnerabilities',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SGStatisticCard(
                        title: 'Critical',
                        value: repo.criticalCount.toString(),
                        icon: Icons.dangerous_rounded,
                        accentColor: AppColors.critical,
                        onTap: () => context.push(AppRouter.findings),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SGStatisticCard(
                        title: 'High',
                        value: repo.highCount.toString(),
                        icon: Icons.warning_rounded,
                        accentColor: AppColors.high,
                        onTap: () => context.push(AppRouter.findings),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SGStatisticCard(
                        title: 'Secret Leaks',
                        value: repo.secretFindings.toString(),
                        icon: Icons.key_rounded,
                        accentColor: AppColors.warning,
                        onTap: () => context.push(AppRouter.findings),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SGStatisticCard(
                        title: 'SAST Issues',
                        value: repo.sastFindings.toString(),
                        icon: Icons.code_rounded,
                        accentColor: AppColors.info,
                        onTap: () => context.push(AppRouter.findings),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Action Buttons
                SGButton(
                  label: 'Trigger Immediate SAST Scan',
                  icon: const Icon(Icons.radar_rounded, color: Colors.white, size: 20),
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Semgrep SAST scan dispatched for ${repo.name}...')),
                          ],
                        ),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    await ref.read(repositoryRepositoryProvider).triggerRepositoryScan(repo.id);
                    ref.invalidate(repositoriesDataProvider);
                    ref.invalidate(liveDashboardNotifierProvider);
                  },
                ),

                const SizedBox(height: 12),

                SGButton(
                  label: 'Ask AI Remediation Copilot',
                  variant: SGButtonVariant.outline,
                  icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
                  onPressed: () {
                    context.go(AppRouter.aiAssistant);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: SGLoading(message: 'Loading repository telemetry...')),
        error: (err, _) => SGErrorView(message: 'Error loading repository: $err'),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
