import 'package:equatable/equatable.dart';

class ReportModel extends Equatable {
  final String id;
  final String title;
  final String category;
  final String format; // PDF, CSV, JSON
  final String fileSize;
  final DateTime generatedAt;

  const ReportModel({
    required this.id,
    required this.title,
    required this.category,
    required this.format,
    required this.fileSize,
    required this.generatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      format: json['format'] as String,
      fileSize: json['file_size'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'format': format,
        'file_size': fileSize,
        'generated_at': generatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, title, category, format, fileSize, generatedAt];
}
