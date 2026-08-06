import 'package:equatable/equatable.dart';
import 'finding_model.dart';

class SocAlertModel extends Equatable {
  final String id;
  final String title;
  final String sourceIp;
  final String targetHost;
  final SeverityLevel severity;
  final String eventType;
  final DateTime timestamp;
  final bool isAcknowledged;

  const SocAlertModel({
    required this.id,
    required this.title,
    required this.sourceIp,
    required this.targetHost,
    required this.severity,
    required this.eventType,
    required this.timestamp,
    required this.isAcknowledged,
  });

  factory SocAlertModel.fromJson(Map<String, dynamic> json) {
    return SocAlertModel(
      id: json['id'] as String,
      title: json['title'] as String,
      sourceIp: json['source_ip'] as String,
      targetHost: json['target_host'] as String,
      severity: SeverityLevel.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SeverityLevel.high,
      ),
      eventType: json['event_type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isAcknowledged: json['is_acknowledged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'source_ip': sourceIp,
        'target_host': targetHost,
        'severity': severity.name,
        'event_type': eventType,
        'timestamp': timestamp.toIso8601String(),
        'is_acknowledged': isAcknowledged,
      };

  @override
  List<Object?> get props => [id, title, sourceIp, targetHost, severity, eventType, timestamp, isAcknowledged];
}
