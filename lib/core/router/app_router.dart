import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/ai/ai_copilot_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/findings/finding_detail_screen.dart';
import '../../features/findings/findings_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/repositories/repositories_screen.dart';
import '../../features/repositories/repository_detail_screen.dart';
import '../../features/scans/scan_detail_screen.dart';
import '../../features/scans/scans_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/soc/soc_screen.dart';
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
  static const String scans = '/scans';
  static const String scanDetail = '/scans/:id';
  static const String soc = '/soc';
  static const String profile = '/profile';

  static const String findings = '/findings';
  static const String findingDetail = '/findings/:id';
  static const String aiCopilot = '/ai-copilot';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

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

      // Shell Route for Bottom Navigation Tabs
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          int currentIndex = 0;
          final location = state.uri.path;
          if (location.startsWith(repositories)) {
            currentIndex = 1;
          } else if (location.startsWith(scans)) {
            currentIndex = 2;
          } else if (location.startsWith(soc)) {
            currentIndex = 3;
          } else if (location.startsWith(profile)) {
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
                    context.go(scans);
                    break;
                  case 3:
                    context.go(soc);
                    break;
                  case 4:
                    context.go(profile);
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
            path: scans,
            builder: (context, state) => const ScansScreen(),
          ),
          GoRoute(
            path: soc,
            builder: (context, state) => const SocScreen(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Detail & Independent Routes (Pushed on top of root navigator)
      GoRoute(
        path: repositoryDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RepositoryDetailScreen(repositoryId: id);
        },
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
        path: aiCopilot,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiCopilotScreen(),
      ),
      GoRoute(
        path: reports,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
