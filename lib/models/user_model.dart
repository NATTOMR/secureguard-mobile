import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String avatarUrl;
  final bool isMfaEnabled;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.isMfaEnabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      avatarUrl: json['avatar_url'] as String? ?? '',
      isMfaEnabled: json['is_mfa_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'avatar_url': avatarUrl,
      'is_mfa_enabled': isMfaEnabled,
    };
  }

  @override
  List<Object?> get props => [id, email, name, role, avatarUrl, isMfaEnabled];
}
