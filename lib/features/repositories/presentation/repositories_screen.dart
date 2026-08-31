import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/widgets.dart';
import '../../../providers/app_providers.dart';
import '../domain/repository_model.dart';

class RepositoriesScreen extends ConsumerStatefulWidget {
  const RepositoriesScreen({super.key});

  @override
  ConsumerState<RepositoriesScreen> createState() => _RepositoriesScreenState();
}

class _RepositoriesScreenState extends ConsumerState<RepositoriesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final reposAsync = ref.watch(repositoriesDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: AppStrings.navRepositories,
        subtitle: 'Monitored Codebases & CI/CD Pipelines',
        showStatusBadge: true,
        statusText: 'GITHUB SYNCED',
        statusType: StatusType.normal,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SGSearchBar(
              hintText: 'Search repositories, owners, or languages...',
              onChanged: (q) {
                setState(() {
                  _searchQuery = q;
                });
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Critical Risk'),
                const SizedBox(width: 8),
                _buildFilterChip('Warning'),
                const SizedBox(width: 8),
                _buildFilterChip('Secure'),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Repositories List
          Expanded(
            child: reposAsync.when(
              data: (repos) {
                final filtered = repos.where((repo) {
                  final matchesSearch = repo.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      repo.owner.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      repo.primaryLanguage.toLowerCase().contains(_searchQuery.toLowerCase());

                  if (!matchesSearch) return false;

                  if (_selectedFilter == 'All') return true;
                  return repo.securityStatus.toLowerCase() == _selectedFilter.toLowerCase();
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: SGEmptyState(
                      title: 'No Repositories Found',
                      subtitle: 'No code repositories match your current search and filter criteria.',
                      icon: Icons.folder_off_outlined,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async => ref.invalidate(repositoriesDataProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final repo = filtered[index];
                      return _buildRepositoryCard(context, repo);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: SGLoading(message: 'Querying GitHub organization repositories...'),
              ),
              error: (err, _) => SGErrorView(
                message: 'Failed to fetch repositories: $err',
                onRetry: () => ref.invalidate(repositoriesDataProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.cardBorder,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
    );
  }

  Widget _buildRepositoryCard(BuildContext context, RepositoryModel repo) {
    final statusColor = repo.securityStatus == 'Critical Risk'
        ? AppColors.critical
        : repo.securityStatus == 'Warning'
            ? AppColors.warning
            : AppColors.success;

    return InkWell(
      onTap: () {
        context.push('${AppRouter.repositories}/${repo.id}');
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
            // Top Row: Owner / Name + Security Health Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.owner,
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        repo.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    repo.securityStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Metadata Chips (Language, Branch, Secrets, SAST)
            Row(
              children: [
                _buildTag(repo.primaryLanguage, Icons.code_rounded, AppColors.textSecondary),
                const SizedBox(width: 8),
                _buildTag(repo.branch, Icons.merge_type_rounded, AppColors.textMuted),
                const SizedBox(width: 8),
                if (repo.isPrivate) _buildTag('Private', Icons.lock_outline_rounded, AppColors.textMuted),
              ],
            ),

            const SizedBox(height: 14),
            Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 12),

            // Findings Breakdown Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFindingMetric('Critical', repo.criticalCount, AppColors.critical),
                _buildFindingMetric('High', repo.highCount, AppColors.high),
                _buildFindingMetric('Secrets', repo.secretFindings, AppColors.warning),
                _buildFindingMetric('SAST', repo.sastFindings, AppColors.info),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Last Scanned', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      _formatScanTime(repo.lastScannedAt),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingMetric(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: count > 0 ? color : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  String _formatScanTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
