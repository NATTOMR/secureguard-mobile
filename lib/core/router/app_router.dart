import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/ai/presentation/ai_assistant_screen.dart';
import '../../features/alerts/presentation/alert_detail_screen.dart';
import '../../features/alerts/presentation/alerts_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/findings/finding_detail_screen.dart';
import '../../features/findings/findings_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/repositories/presentation/repositories_screen.dart';
import '../../features/repositories/presentation/repository_detail_screen.dart';
import '../../features/scans/scan_detail_screen.dart';
import '../../features/scans/scans_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../widgets/sg_bottom_navigation.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shellNav');

class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String repositories = '/repositories';
  static const String repositoryDetail = '/repositories/:id';
  static const String aiAssistant = '/ai';
  static const String aiCopilot = '/ai';
  static const String alerts = '/alerts';
  static const String alertDetail = '/alerts/:id';
  static const String soc = '/alerts';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Secondary Workflows
  static const String scans = '/scans';
  static const String scanDetail = '/scans/:id';
  static const String findings = '/findings';
  static const String findingDetail = '/findings/:id';
  static const String reports = '/reports';

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Main 5-Tab Navigation Shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          int currentIndex = 0;
          final location = state.uri.path;
          if (location.startsWith(repositories)) {
            currentIndex = 1;
          } else if (location.startsWith(aiAssistant)) {
            currentIndex = 2;
          } else if (location.startsWith(alerts)) {
            currentIndex = 3;
          } else if (location.startsWith(settings)) {
            currentIndex = 4;
          }

          return Scaffold(
            body: child,
            bottomNavigationBar: SGBottomNavigation(
              currentIndex: currentIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go(dashboard);
                    break;
                  case 1:
                    context.go(repositories);
                    break;
                  case 2:
                    context.go(aiAssistant);
                    break;
                  case 3:
                    context.go(alerts);
                    break;
                  case 4:
                    context.go(settings);
                    break;
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: repositories,
            builder: (context, state) => const RepositoriesScreen(),
          ),
          GoRoute(
            path: aiAssistant,
            builder: (context, state) => const AiAssistantScreen(),
          ),
          GoRoute(
            path: alerts,
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Detail & Secondary Modal Routes
      GoRoute(
        path: repositoryDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RepositoryDetailScreen(repositoryId: id);
        },
      ),
      GoRoute(
        path: alertDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AlertDetailScreen(alertId: id);
        },
      ),
      GoRoute(
        path: scans,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScansScreen(),
      ),
      GoRoute(
        path: scanDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ScanDetailScreen(scanId: id);
        },
      ),
      GoRoute(
        path: findings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FindingsScreen(),
      ),
      GoRoute(
        path: findingDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return FindingDetailScreen(findingId: id);
        },
      ),
      GoRoute(
        path: reports,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: profile,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
