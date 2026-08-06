import 'package:equatable/equatable.dart';

enum ScanType { sast, dast, dependency, container, secret }
enum ScanStatus { inProgress, completed, failed }

class ScanModel extends Equatable {
  final String id;
  final String targetName;
  final ScanType type;
  final ScanStatus status;
  final int findingsCount;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String triggerBy;

  const ScanModel({
    required this.id,
    required this.targetName,
    required this.type,
    required this.status,
    required this.findingsCount,
    required this.startedAt,
    this.completedAt,
    required this.triggerBy,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'] as String,
      targetName: json['target_name'] as String,
      type: ScanType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScanType.sast,
      ),
      status: ScanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ScanStatus.completed,
      ),
      findingsCount: json['findings_count'] as int? ?? 0,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      triggerBy: json['trigger_by'] as String? ?? 'Automated CI/CD',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'target_name': targetName,
        'type': type.name,
        'status': status.name,
        'findings_count': findingsCount,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'trigger_by': triggerBy,
      };

  @override
  List<Object?> get props => [id, targetName, type, status, findingsCount, startedAt, completedAt, triggerBy];
}
