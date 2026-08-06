import '../models/dashboard_model.dart';

class DashboardRepository {
  Future<DashboardModel> getDashboardSummary() async {
    // Simulate real enterprise network delay
    await Future.delayed(const Duration(milliseconds: 750));

    return const DashboardModel(
      totalRepositories: 32,
      totalScansToday: 184,
      criticalCount: 4,
      highCount: 14,
      mediumCount: 29,
      lowCount: 65,
      socAlertsCount: 9,
      githubIssuesCount: 23,
      systemStatuses: [
        SystemStatusModel(name: 'Backend Gateway', status: 'operational', latencyMs: 18),
        SystemStatusModel(name: 'GitHub Sync API', status: 'operational', latencyMs: 42),
        SystemStatusModel(name: 'AI Remediation Engine', status: 'operational', latencyMs: 85),
        SystemStatusModel(name: 'SOC SIEM Feed', status: 'operational', latencyMs: 12),
        SystemStatusModel(name: 'PostgreSQL Vault', status: 'operational', latencyMs: 6),
      ],
    );
  }
}
