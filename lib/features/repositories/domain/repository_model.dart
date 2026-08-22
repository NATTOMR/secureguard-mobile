import 'package:equatable/equatable.dart';

class RepositoryModel extends Equatable {
  final String id;
  final String name;
  final String owner;
  final String primaryLanguage;
  final String branch;
  final bool isPrivate;
  final String securityStatus; // 'Secure', 'Warning', 'Critical Risk'
  final int criticalCount;
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int secretFindings;
  final int sastFindings;
  final String securityHealthScore; // 'A', 'B', 'C', 'F'
  final DateTime lastScannedAt;

  const RepositoryModel({
    required this.id,
    required this.name,
    required this.owner,
    required this.primaryLanguage,
    this.branch = 'main',
    this.isPrivate = true,
    this.securityStatus = 'Secure',
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    this.secretFindings = 0,
    this.sastFindings = 0,
    required this.securityHealthScore,
    required this.lastScannedAt,
  });

  int get totalVulnerabilities => criticalCount + highCount + mediumCount + lowCount;

  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    return RepositoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      owner: json['owner'] as String,
      primaryLanguage: json['primary_language'] as String? ?? 'Python',
      branch: json['branch'] as String? ?? 'main',
      isPrivate: json['is_private'] as bool? ?? true,
      securityStatus: json['security_status'] as String? ?? 'Secure',
      criticalCount: json['critical_count'] as int? ?? 0,
      highCount: json['high_count'] as int? ?? 0,
      mediumCount: json['medium_count'] as int? ?? 0,
      lowCount: json['low_count'] as int? ?? 0,
      secretFindings: json['secret_findings'] as int? ?? 0,
      sastFindings: json['sast_findings'] as int? ?? 0,
      securityHealthScore: json['security_health_score'] as String? ?? 'A',
      lastScannedAt: DateTime.tryParse(json['last_scanned_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'owner': owner,
        'primary_language': primaryLanguage,
        'branch': branch,
        'is_private': isPrivate,
        'security_status': securityStatus,
        'critical_count': criticalCount,
        'high_count': highCount,
        'medium_count': mediumCount,
        'low_count': lowCount,
        'secret_findings': secretFindings,
        'sast_findings': sastFindings,
        'security_health_score': securityHealthScore,
        'last_scanned_at': lastScannedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        owner,
        primaryLanguage,
        branch,
        isPrivate,
        securityStatus,
        criticalCount,
        highCount,
        mediumCount,
        lowCount,
        secretFindings,
        sastFindings,
        securityHealthScore,
        lastScannedAt,
      ];
}
