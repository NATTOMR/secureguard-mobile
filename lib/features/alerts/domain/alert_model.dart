import 'package:equatable/equatable.dart';

enum AlertSeverity { critical, high, medium, low, informational }

enum AlertStatus { active, investigating, resolved, suppressed }

class AlertModel extends Equatable {
  final String id;
  final AlertSeverity severity;
  final String title;
  final String description;
  final DateTime timestamp;
  final String source; // 'Wazuh', 'Splunk', 'Microsoft Sentinel', 'Elastic', 'TheHive', 'GitHub App', 'Semgrep'
  final AlertStatus status;
  final String? remediationRecommendation;

  const AlertModel({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.source,
    required this.status,
    this.remediationRecommendation,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    final sevStr = (json['severity'] as String? ?? 'medium').toLowerCase();
    final statStr = (json['status'] as String? ?? 'active').toLowerCase();

    return AlertModel(
      id: json['id'] as String? ?? '',
      severity: _parseSeverity(sevStr),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      source: json['source'] as String? ?? 'Wazuh SOC',
      status: _parseStatus(statStr),
      remediationRecommendation: json['remediation_recommendation'] as String?,
    );
  }

  static AlertSeverity _parseSeverity(String val) {
    switch (val) {
      case 'critical':
        return AlertSeverity.critical;
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      case 'low':
        return AlertSeverity.low;
      default:
        return AlertSeverity.informational;
    }
  }

  static AlertStatus _parseStatus(String val) {
    switch (val) {
      case 'investigating':
        return AlertStatus.investigating;
      case 'resolved':
        return AlertStatus.resolved;
      case 'suppressed':
        return AlertStatus.suppressed;
      default:
        return AlertStatus.active;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'severity': severity.name,
        'title': title,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'source': source,
        'status': status.name,
        'remediation_recommendation': remediationRecommendation,
      };

  @override
  List<Object?> get props => [id, severity, title, description, timestamp, source, status, remediationRecommendation];
}
