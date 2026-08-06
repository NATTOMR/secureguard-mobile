import '../models/user_model.dart';

class AuthRepository {
  Future<UserModel> loginWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return const UserModel(
      id: 'usr_8921',
      email: 'analyst@secureguard.enterprise',
      name: 'Alex Vance',
      role: 'Lead Security Architect',
      avatarUrl: '',
      isMfaEnabled: true,
    );
  }

  Future<UserModel> loginWithGithub() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    return const UserModel(
      id: 'usr_gh_4412',
      email: 'alex.vance@github.corp',
      name: 'Alex Vance (GitHub)',
      role: 'DevSecOps Admin',
      avatarUrl: '',
      isMfaEnabled: true,
    );
  }

  Future<UserModel> loginOffline() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const UserModel(
      id: 'usr_offline_001',
      email: 'offline.sec@local',
      name: 'Offline Security Officer',
      role: 'Security Analyst (Cached)',
      avatarUrl: '',
      isMfaEnabled: false,
    );
  }
}
