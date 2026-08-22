import 'package:equatable/equatable.dart';

enum AiMessageRole { user, assistant, system }

class AiMessageModel extends Equatable {
  final String id;
  final AiMessageRole role;
  final String content;
  final DateTime timestamp;
  final bool hasCode;
  final String? codeSnippet;

  const AiMessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.hasCode = false,
    this.codeSnippet,
  });

  factory AiMessageModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'assistant';
    return AiMessageModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: roleStr == 'user'
          ? AiMessageRole.user
          : roleStr == 'system'
              ? AiMessageRole.system
              : AiMessageRole.assistant,
      content: json['content'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      hasCode: json['has_code'] as bool? ?? false,
      codeSnippet: json['code_snippet'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'has_code': hasCode,
        'code_snippet': codeSnippet,
      };

  @override
  List<Object?> get props => [id, role, content, timestamp, hasCode, codeSnippet];
}
