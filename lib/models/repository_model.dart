import 'package:equatable/equatable.dart';

class RepositoryModel extends Equatable {
  final String id;
  final String name;
  final String owner;
  final String primaryLanguage;
  final int criticalCount;
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final String securityHealthScore;
  final DateTime lastScannedAt;

  const RepositoryModel({
    required this.id,
    required this.name,
    required this.owner,
    required this.primaryLanguage,
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    required this.securityHealthScore,
    required this.lastScannedAt,
  });

  int get totalVulnerabilities => criticalCount + highCount + mediumCount + lowCount;

  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    return RepositoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      owner: json['owner'] as String,
      primaryLanguage: json['primary_language'] as String,
      criticalCount: json['critical_count'] as int? ?? 0,
      highCount: json['high_count'] as int? ?? 0,
      mediumCount: json['medium_count'] as int? ?? 0,
      lowCount: json['low_count'] as int? ?? 0,
      securityHealthScore: json['security_health_score'] as String? ?? 'A',
      lastScannedAt: DateTime.parse(json['last_scanned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'owner': owner,
        'primary_language': primaryLanguage,
        'critical_count': criticalCount,
        'high_count': highCount,
        'medium_count': mediumCount,
        'low_count': lowCount,
        'security_health_score': securityHealthScore,
        'last_scanned_at': lastScannedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        owner,
        primaryLanguage,
        criticalCount,
        highCount,
        mediumCount,
        lowCount,
        securityHealthScore,
        lastScannedAt,
      ];
}
