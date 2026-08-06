import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../../providers/app_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _searchQuery = '';
  late String _currentTimeString;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _currentTimeString = DateFormat('EEE, MMM dd • HH:mm:ss').format(now);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final findingsAsync = ref.watch(findingsListProvider);
    final reposAsync = ref.watch(repositoriesListProvider);
    final userState = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(findingsListProvider);
            ref.invalidate(repositoriesListProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP ENTERPRISE HEADER
                _buildTopHeader(context, userState),

                const SizedBox(height: 20),

                // 2. GLOBAL SEARCH BAR
                SGSearchBar(
                  hintText: 'Search repositories, CVEs, scans, or GitHub issues...',
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // SUMMARY ASYNC HANDLING
                summaryAsync.when(
                  loading: () => _buildShimmerSkeleton(),
                  error: (err, st) => SGErrorView(
                    errorMessage: err.toString(),
                    onRetry: () => ref.invalidate(dashboardSummaryProvider),
                  ),
                  data: (data) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3. STATISTICS CARDS (8 CARDS GRID)
                        _buildStatisticsGrid(context, data),

                        const SizedBox(height: 24),

                        // 4. LIVE SYSTEM STATUS CARDS
                        StatusCard(systemStatuses: data.systemStatuses)
                            .animate()
                            .fadeIn(delay: 250.ms),

                        const SizedBox(height: 28),

                        // 5. CHARTS SECTION (4 VISUAL CHARTS)
                        _buildChartsSection(context, data),

                        const SizedBox(height: 28),

                        // 6. RECENT FINDINGS
                        _buildRecentFindingsSection(context, findingsAsync),

                        const SizedBox(height: 28),

                        // 7. RECENT REPOSITORIES
                        _buildRecentRepositoriesSection(context, reposAsync),

                        const SizedBox(height: 28),

                        // 8. ENTERPRISE QUICK ACTIONS GRID
                        _buildQuickActionsGrid(context),

                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER SECTION
  // ---------------------------------------------------------------------------
  Widget _buildTopHeader(BuildContext context, UserModel? userState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${userState?.name ?? "Alex Vance"}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentTimeString,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () => context.push(AppRouter.notifications),
            ),
            const SizedBox(width: 4),
            const SGAvatar(initials: 'AV', radius: 20),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ---------------------------------------------------------------------------
  // 8 STATISTICS CARDS GRID
  // ---------------------------------------------------------------------------
  Widget _buildStatisticsGrid(BuildContext context, DashboardModel data) {
    final stats = [
      {
        'title': 'Monitored Repos',
        'count': data.totalRepositories,
        'icon': Icons.folder_special_rounded,
        'color': AppColors.primary,
        'onTap': () => context.push(AppRouter.repositories),
      },
      {
        'title': 'Scans Today',
        'count': data.totalScansToday,
        'icon': Icons.radar_rounded,
        'color': AppColors.info,
        'onTap': () => context.push(AppRouter.scans),
      },
      {
        'title': 'Critical Findings',
        'count': data.criticalCount,
        'icon': Icons.gpp_maybe_rounded,
        'color': AppColors.critical,
        'onTap': () => context.push(AppRouter.findings),
      },
      {
        'title': 'High Findings',
        'count': data.highCount,
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.high,
        'onTap': () => context.push(AppRouter.findings),
      },
      {
        'title': 'Medium Findings',
        'count': data.mediumCount,
        'icon': Icons.error_outline_rounded,
        'color': AppColors.warning,
        'onTap': () => context.push(AppRouter.findings),
      },
      {
        'title': 'Low Findings',
        'count': data.lowCount,
        'icon': Icons.info_outline_rounded,
        'color': AppColors.low,
        'onTap': () => context.push(AppRouter.findings),
      },
      {
        'title': 'SOC SIEM Alerts',
        'count': data.socAlertsCount,
        'icon': Icons.security_rounded,
        'color': Colors.purpleAccent,
        'onTap': () => context.push(AppRouter.soc),
      },
      {
        'title': 'GitHub Issues',
        'count': data.githubIssuesCount,
        'icon': Icons.bug_report_rounded,
        'color': Colors.tealAccent,
        'onTap': () => context.push(AppRouter.repositories),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isWide ? 1.45 : 1.25,
          ),
          itemBuilder: (context, index) {
            final item = stats[index];
            return StatisticCard(
              title: item['title'] as String,
              count: item['count'] as int,
              icon: item['icon'] as IconData,
              accentColor: item['color'] as Color,
              onTap: item['onTap'] as VoidCallback?,
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 4 EXECUTIVE CHARTS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildChartsSection(BuildContext context, DashboardModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Executive Security Insights & Metrics',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),

        // Row 1: Pie Chart & Bar Chart
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            final pieChart = ChartCard(
              title: 'Vulnerability Severity Split',
              badgeLabel: '${data.totalVulnerabilities} TOTAL',
              chartWidget: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 36,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.critical,
                      value: data.criticalCount.toDouble(),
                      title: 'Crit',
                      radius: 35,
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: AppColors.high,
                      value: data.highCount.toDouble(),
                      title: 'High',
                      radius: 35,
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: AppColors.warning,
                      value: data.mediumCount.toDouble(),
                      title: 'Med',
                      radius: 35,
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: AppColors.low,
                      value: data.lowCount.toDouble(),
                      title: 'Low',
                      radius: 35,
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );

            final barChart = ChartCard(
              title: 'Weekly Scan Volume',
              badgeLabel: '7-DAY ENGINE',
              chartWidget: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          if (val.toInt() >= 0 && val.toInt() < days.length) {
                            return Text(days[val.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 11));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _buildBarGroup(0, 18),
                    _buildBarGroup(1, 24),
                    _buildBarGroup(2, 19),
                    _buildBarGroup(3, 32),
                    _buildBarGroup(4, 28),
                    _buildBarGroup(5, 14),
                    _buildBarGroup(6, 42),
                  ],
                ),
              ),
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: pieChart),
                  const SizedBox(width: 14),
                  Expanded(child: barChart),
                ],
              );
            }

            return Column(
              children: [
                pieChart,
                const SizedBox(height: 14),
                barChart,
              ],
            );
          },
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 14,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 50,
            color: AppColors.surface,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // RECENT FINDINGS SECTION
  // ---------------------------------------------------------------------------
  Widget _buildRecentFindingsSection(BuildContext context, AsyncValue<List<FindingModel>> findingsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Security Findings',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => context.push(AppRouter.findings),
              child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        findingsAsync.when(
          loading: () => const SGLoading(message: 'Fetching Findings...'),
          error: (err, st) => Text('Error: $err', style: const TextStyle(color: AppColors.critical)),
          data: (findings) {
            final filtered = findings.where((f) {
              return f.title.toLowerCase().contains(_searchQuery) ||
                  f.cveId.toLowerCase().contains(_searchQuery) ||
                  f.repositoryName.toLowerCase().contains(_searchQuery);
            }).take(3).toList();

            if (filtered.isEmpty) {
              return const SGEmptyState(
                title: 'No Findings Match',
                description: 'Try adjusting your global search query.',
                icon: Icons.verified_user_rounded,
              );
            }

            return Column(
              children: filtered.map((finding) {
                return FindingCard(
                  finding: finding,
                  onTap: () => context.push('/findings/${finding.id}'),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // RECENT REPOSITORIES SECTION
  // ---------------------------------------------------------------------------
  Widget _buildRecentRepositoriesSection(BuildContext context, AsyncValue<List<RepositoryModel>> reposAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Monitored Repositories Overview',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            TextButton(
              onPressed: () => context.push(AppRouter.repositories),
              child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        reposAsync.when(
          loading: () => const SGLoading(message: 'Loading Repositories...'),
          error: (err, st) => Text('Error: $err', style: const TextStyle(color: AppColors.critical)),
          data: (repos) {
            final filtered = repos.where((r) {
              return r.name.toLowerCase().contains(_searchQuery) ||
                  r.primaryLanguage.toLowerCase().contains(_searchQuery);
            }).take(3).toList();

            if (filtered.isEmpty) {
              return const SGEmptyState(
                title: 'No Repositories Match',
                description: 'Try adjusting your global search query.',
                icon: Icons.folder_open_rounded,
              );
            }

            return Column(
              children: filtered.map((repo) {
                return RepositoryCard(
                  repository: repo,
                  onTap: () => context.push('/repositories/${repo.id}'),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // QUICK ACTIONS GRID
  // ---------------------------------------------------------------------------
  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {
        'title': 'Run Scan',
        'sub': 'Launch SAST engine',
        'icon': Icons.play_arrow_rounded,
        'color': AppColors.primary,
        'onTap': () => context.push(AppRouter.scans),
      },
      {
        'title': 'Repositories',
        'sub': 'Code audit',
        'icon': Icons.folder_open_rounded,
        'color': AppColors.info,
        'onTap': () => context.push(AppRouter.repositories),
      },
      {
        'title': 'AI Assistant',
        'sub': 'Remediation LLM',
        'icon': Icons.psychology_rounded,
        'color': Colors.purpleAccent,
        'onTap': () => context.push(AppRouter.aiCopilot),
      },
      {
        'title': 'SOC Center',
        'sub': 'SIEM live feed',
        'icon': Icons.security_rounded,
        'color': AppColors.critical,
        'onTap': () => context.push(AppRouter.soc),
      },
      {
        'title': 'Reports',
        'sub': 'PDF audit logs',
        'icon': Icons.assessment_rounded,
        'color': AppColors.success,
        'onTap': () => context.push(AppRouter.reports),
      },
      {
        'title': 'GitHub Issues',
        'sub': 'Security PRs',
        'icon': Icons.bug_report_rounded,
        'color': AppColors.warning,
        'onTap': () => context.push(AppRouter.repositories),
      },
      {
        'title': 'Settings',
        'sub': 'Biometrics & preferences',
        'icon': Icons.settings_rounded,
        'color': AppColors.textSecondary,
        'onTap': () => context.push(AppRouter.settings),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enterprise Quick Actions Hub',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isWide ? 1.5 : 1.35,
              ),
              itemBuilder: (context, index) {
                final item = actions[index];
                return QuickActionCard(
                  title: item['title'] as String,
                  subtitle: item['sub'] as String,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                  onTap: item['onTap'] as VoidCallback,
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SHIMMER SKELETON LOADING STATE
  // ---------------------------------------------------------------------------
  Widget _buildShimmerSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.card,
      child: Column(
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.card, borderRadius: AppColors.cardBorderRadius),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.card, borderRadius: AppColors.cardBorderRadius),
          ),
          const SizedBox(height: 20),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.card, borderRadius: AppColors.cardBorderRadius),
          ),
        ],
      ),
    );
  }
}
