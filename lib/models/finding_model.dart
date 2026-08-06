import 'package:equatable/equatable.dart';

enum SeverityLevel { critical, high, medium, low }

class FindingModel extends Equatable {
  final String id;
  final String cveId;
  final String title;
  final String description;
  final SeverityLevel severity;
  final double cvssScore;
  final String repositoryName;
  final String filePath;
  final int lineNumber;
  final String remediationGuide;
  final bool isResolved;
  final DateTime detectedAt;

  const FindingModel({
    required this.id,
    required this.cveId,
    required this.title,
    required this.description,
    required this.severity,
    required this.cvssScore,
    required this.repositoryName,
    required this.filePath,
    required this.lineNumber,
    required this.remediationGuide,
    required this.isResolved,
    required this.detectedAt,
  });

  factory FindingModel.fromJson(Map<String, dynamic> json) {
    return FindingModel(
      id: json['id'] as String,
      cveId: json['cve_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: SeverityLevel.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SeverityLevel.high,
      ),
      cvssScore: (json['cvss_score'] as num).toDouble(),
      repositoryName: json['repository_name'] as String,
      filePath: json['file_path'] as String,
      lineNumber: json['line_number'] as int? ?? 1,
      remediationGuide: json['remediation_guide'] as String,
      isResolved: json['is_resolved'] as bool? ?? false,
      detectedAt: DateTime.parse(json['detected_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cve_id': cveId,
        'title': title,
        'description': description,
        'severity': severity.name,
        'cvss_score': cvssScore,
        'repository_name': repositoryName,
        'file_path': filePath,
        'line_number': lineNumber,
        'remediation_guide': remediationGuide,
        'is_resolved': isResolved,
        'detected_at': detectedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        cveId,
        title,
        description,
        severity,
        cvssScore,
        repositoryName,
        filePath,
        lineNumber,
        remediationGuide,
        isResolved,
        detectedAt,
      ];
}
