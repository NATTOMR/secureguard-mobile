import 'package:equatable/equatable.dart';

class SystemStatusModel extends Equatable {
  final String name;
  final String status; // 'operational', 'degraded', 'maintenance'
  final int latencyMs;

  const SystemStatusModel({
    required this.name,
    required this.status,
    required this.latencyMs,
  });

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) {
    return SystemStatusModel(
      name: json['name'] as String,
      status: json['status'] as String? ?? 'operational',
      latencyMs: json['latency_ms'] as int? ?? 24,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'status': status,
        'latency_ms': latencyMs,
      };

  @override
  List<Object?> get props => [name, status, latencyMs];
}

class DashboardModel extends Equatable {
  final int totalRepositories;
  final int totalScansToday;
  final int criticalCount;
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int socAlertsCount;
  final int githubIssuesCount;
  final List<SystemStatusModel> systemStatuses;

  const DashboardModel({
    required this.totalRepositories,
    required this.totalScansToday,
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    required this.socAlertsCount,
    required this.githubIssuesCount,
    required this.systemStatuses,
  });

  int get totalVulnerabilities => criticalCount + highCount + mediumCount + lowCount;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalRepositories: json['total_repositories'] as int? ?? 28,
      totalScansToday: json['total_scans_today'] as int? ?? 142,
      criticalCount: json['critical_count'] as int? ?? 3,
      highCount: json['high_count'] as int? ?? 12,
      mediumCount: json['medium_count'] as int? ?? 24,
      lowCount: json['low_count'] as int? ?? 58,
      socAlertsCount: json['soc_alerts_count'] as int? ?? 7,
      githubIssuesCount: json['github_issues_count'] as int? ?? 19,
      systemStatuses: (json['system_statuses'] as List<dynamic>?)
              ?.map((e) => SystemStatusModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_repositories': totalRepositories,
        'total_scans_today': totalScansToday,
        'critical_count': criticalCount,
        'high_count': highCount,
        'medium_count': mediumCount,
        'low_count': lowCount,
        'soc_alerts_count': socAlertsCount,
        'github_issues_count': githubIssuesCount,
        'system_statuses': systemStatuses.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        totalRepositories,
        totalScansToday,
        criticalCount,
        highCount,
        mediumCount,
        lowCount,
        socAlertsCount,
        githubIssuesCount,
        systemStatuses,
      ];
}
