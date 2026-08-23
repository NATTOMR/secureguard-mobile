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

class SecurityEventSummary extends Equatable {
  final String id;
  final String title;
  final String source; // 'Wazuh', 'Splunk', 'GitHub App', 'Semgrep'
  final String severity; // 'Critical', 'High', 'Medium', 'Low'
  final DateTime timestamp;

  const SecurityEventSummary({
    required this.id,
    required this.title,
    required this.source,
    required this.severity,
    required this.timestamp,
  });

  factory SecurityEventSummary.fromJson(Map<String, dynamic> json) {
    return SecurityEventSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      source: json['source'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'source': source,
        'severity': severity,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, title, source, severity, timestamp];
}

class RecentScanSummary extends Equatable {
  final String id;
  final String target;
  final String scanType; // 'Semgrep SAST', 'Secret Scanning', 'Container Scan'
  final String status; // 'Passed', 'Failed', 'In Progress'
  final int findingsCount;
  final String duration;
  final DateTime timestamp;

  const RecentScanSummary({
    required this.id,
    required this.target,
    required this.scanType,
    required this.status,
    required this.findingsCount,
    required this.duration,
    required this.timestamp,
  });

  factory RecentScanSummary.fromJson(Map<String, dynamic> json) {
    return RecentScanSummary(
      id: json['id'] as String,
      target: json['target'] as String,
      scanType: json['scan_type'] as String,
      status: json['status'] as String,
      findingsCount: json['findings_count'] as int? ?? 0,
      duration: json['duration'] as String? ?? '14s',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'target': target,
        'scan_type': scanType,
        'status': status,
        'findings_count': findingsCount,
        'duration': duration,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, target, scanType, status, findingsCount, duration, timestamp];
}

class DashboardModel extends Equatable {
  final int postureScore; // 0 to 100
  final String postureStatus; // 'Secure', 'Elevated Risk', 'Critical Attention'
  final int totalRepositories;
  final int totalScansToday;
  final int criticalCount;
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int activeAlertsCount;
  final List<SystemStatusModel> systemStatuses;
  final List<SecurityEventSummary> recentEvents;
  final List<RecentScanSummary> recentScans;

  const DashboardModel({
    required this.postureScore,
    required this.postureStatus,
    required this.totalRepositories,
    required this.totalScansToday,
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    required this.activeAlertsCount,
    required this.systemStatuses,
    required this.recentEvents,
    required this.recentScans,
  });

  int get totalVulnerabilities => criticalCount + highCount + mediumCount + lowCount;

  DashboardModel copyWith({
    int? postureScore,
    String? postureStatus,
    int? totalRepositories,
    int? totalScansToday,
    int? criticalCount,
    int? highCount,
    int? mediumCount,
    int? lowCount,
    int? activeAlertsCount,
    List<SystemStatusModel>? systemStatuses,
    List<SecurityEventSummary>? recentEvents,
    List<RecentScanSummary>? recentScans,
  }) {
    return DashboardModel(
      postureScore: postureScore ?? this.postureScore,
      postureStatus: postureStatus ?? this.postureStatus,
      totalRepositories: totalRepositories ?? this.totalRepositories,
      totalScansToday: totalScansToday ?? this.totalScansToday,
      criticalCount: criticalCount ?? this.criticalCount,
      highCount: highCount ?? this.highCount,
      mediumCount: mediumCount ?? this.mediumCount,
      lowCount: lowCount ?? this.lowCount,
      activeAlertsCount: activeAlertsCount ?? this.activeAlertsCount,
      systemStatuses: systemStatuses ?? this.systemStatuses,
      recentEvents: recentEvents ?? this.recentEvents,
      recentScans: recentScans ?? this.recentScans,
    );
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      postureScore: json['posture_score'] as int? ?? 88,
      postureStatus: json['posture_status'] as String? ?? 'Secure',
      totalRepositories: json['total_repositories'] as int? ?? 28,
      totalScansToday: json['total_scans_today'] as int? ?? 142,
      criticalCount: json['critical_count'] as int? ?? 3,
      highCount: json['high_count'] as int? ?? 12,
      mediumCount: json['medium_count'] as int? ?? 24,
      lowCount: json['low_count'] as int? ?? 58,
      activeAlertsCount: json['active_alerts_count'] as int? ?? 7,
      systemStatuses: (json['system_statuses'] as List<dynamic>?)
              ?.map((e) => SystemStatusModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentEvents: (json['recent_events'] as List<dynamic>?)
              ?.map((e) => SecurityEventSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentScans: (json['recent_scans'] as List<dynamic>?)
              ?.map((e) => RecentScanSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'posture_score': postureScore,
        'posture_status': postureStatus,
        'total_repositories': totalRepositories,
        'total_scans_today': totalScansToday,
        'critical_count': criticalCount,
        'high_count': highCount,
        'medium_count': mediumCount,
        'low_count': lowCount,
        'active_alerts_count': activeAlertsCount,
        'system_statuses': systemStatuses.map((e) => e.toJson()).toList(),
        'recent_events': recentEvents.map((e) => e.toJson()).toList(),
        'recent_scans': recentScans.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        postureScore,
        postureStatus,
        totalRepositories,
        totalScansToday,
        criticalCount,
        highCount,
        mediumCount,
        lowCount,
        activeAlertsCount,
        systemStatuses,
        recentEvents,
        recentScans,
      ];
}
