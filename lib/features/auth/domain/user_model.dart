import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // e.g., 'Lead Security Analyst', 'DevSecOps Engineer'
  final String organization;
  final bool mfaEnabled;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.organization,
    this.mfaEnabled = true,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? 'Security Analyst',
      role: json['role'] as String? ?? 'SOC Analyst',
      organization: json['organization'] as String? ?? 'Enterprise Security Ops',
      mfaEnabled: json['mfa_enabled'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'organization': organization,
      'mfa_enabled': mfaEnabled,
      'avatar_url': avatarUrl,
    };
  }

  @override
  List<Object?> get props => [id, email, name, role, organization, mfaEnabled, avatarUrl];
}
