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

class RepositoriesScreen extends ConsumerStatefulWidget {
  const RepositoriesScreen({super.key});

  @override
  ConsumerState<RepositoriesScreen> createState() => _RepositoriesScreenState();
}

class _RepositoriesScreenState extends ConsumerState<RepositoriesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final reposAsync = ref.watch(repositoriesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: AppStrings.monitoredRepos,
        showBackButton: false,
        showStatusBadge: true,
        statusText: '28 MONITORED',
        statusType: StatusType.normal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SGSearchBar(
              hintText: 'Search repositories by name or language...',
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: reposAsync.when(
              loading: () => const SGLoading(message: 'Scanning Code Repositories...'),
              error: (err, st) => SGErrorView(
                errorMessage: err.toString(),
                onRetry: () => ref.refresh(repositoriesListProvider),
              ),
              data: (repos) {
                final filtered = repos.where((r) {
                  return r.name.toLowerCase().contains(_searchQuery) ||
                      r.primaryLanguage.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const SGEmptyState(
                    title: 'No Repositories Found',
                    description: 'No repositories match your search query filter.',
                    icon: Icons.folder_open_rounded,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final repo = filtered[index];
                    return _buildRepoCard(context, repo, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoCard(BuildContext context, RepositoryModel repo, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SGCard(
        onTap: () {
          context.push('/repositories/${repo.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.source_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${repo.owner} • ${repo.primaryLanguage}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'GRADE ${repo.securityHealthScore}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Vulnerability counts row
            Row(
              children: [
                _buildCountBadge('Critical', repo.criticalCount, AppColors.critical),
                const SizedBox(width: 8),
                _buildCountBadge('High', repo.highCount, AppColors.high),
                const SizedBox(width: 8),
                _buildCountBadge('Medium', repo.mediumCount, AppColors.warning),
                const SizedBox(width: 8),
                _buildCountBadge('Low', repo.lowCount, AppColors.low),
                const Spacer(),
                Text(
                  AppFormatters.formatShortDate(repo.lastScannedAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms),
    );
  }

  Widget _buildCountBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
