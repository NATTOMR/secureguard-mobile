import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';

class FindingsScreen extends ConsumerStatefulWidget {
  const FindingsScreen({super.key});

  @override
  ConsumerState<FindingsScreen> createState() => _FindingsScreenState();
}

class _FindingsScreenState extends ConsumerState<FindingsScreen> {
  SeverityLevel? _selectedSeverity;

  @override
  Widget build(BuildContext context) {
    final findingsAsync = ref.watch(findingsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: AppStrings.vulnerabilityFindings,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('ALL', null),
                const SizedBox(width: 8),
                _buildFilterChip('CRITICAL', SeverityLevel.critical),
                const SizedBox(width: 8),
                _buildFilterChip('HIGH', SeverityLevel.high),
                const SizedBox(width: 8),
                _buildFilterChip('MEDIUM', SeverityLevel.medium),
                const SizedBox(width: 8),
                _buildFilterChip('LOW', SeverityLevel.low),
              ],
            ),
          ),

          Expanded(
            child: findingsAsync.when(
              loading: () => const SGLoading(message: 'Querying Vulnerability DB...'),
              error: (err, st) => SGErrorView(
                errorMessage: err.toString(),
                onRetry: () => ref.refresh(findingsListProvider),
              ),
              data: (findings) {
                final filtered = _selectedSeverity == null
                    ? findings
                    : findings.where((f) => f.severity == _selectedSeverity).toList();

                if (filtered.isEmpty) {
                  return const SGEmptyState(
                    title: 'No Findings Detected',
                    description: 'No security findings match the selected severity filter.',
                    icon: Icons.verified_user_rounded,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final finding = filtered[index];
                    return _buildFindingCard(context, finding, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SeverityLevel? level) {
    final isSelected = _selectedSeverity == level;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      onSelected: (val) {
        setState(() {
          _selectedSeverity = val ? level : null;
        });
      },
    );
  }

  Widget _buildFindingCard(BuildContext context, FindingModel finding, int index) {
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SGCard(
        onTap: () => context.push('/findings/${finding.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  finding.cveId,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        'CVSS ${finding.cvssScore}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SGChip(label: finding.severity.name, variant: chipVariant),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              finding.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              finding.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.code_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${finding.repositoryName} • ${finding.filePath}:${finding.lineNumber}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms),
    );
  }
}
