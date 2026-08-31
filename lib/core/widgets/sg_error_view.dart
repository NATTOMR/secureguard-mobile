import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'sg_button.dart';

class SGErrorView extends StatelessWidget {
  final String title;
  final String? errorMessage;
  final String? message;
  final VoidCallback? onRetry;

  const SGErrorView({
    super.key,
    this.title = 'Security Telemetry Error',
    this.errorMessage,
    this.message,
    this.onRetry,
  });

  String get effectiveMessage => errorMessage ?? message ?? 'An unexpected network error occurred.';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.critical.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.critical.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.gpp_maybe_rounded, size: 44, color: AppColors.critical),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              effectiveMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (effectiveMessage.contains('401') || effectiveMessage.toLowerCase().contains('authentication') || effectiveMessage.toLowerCase().contains('token')) ...[
              const SizedBox(height: 20),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SGButton(
                    label: 'Log In',
                    icon: const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                    onPressed: () {
                      try {
                        GoRouter.of(context).go('/login');
                      } catch (_) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    width: 220,
                    height: 42,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 10),
                    SGButton(
                      label: 'Retry Connection',
                      onPressed: onRetry,
                      width: 220,
                      height: 42,
                      variant: SGButtonVariant.secondary,
                    ),
                  ],
                ],
              ),
            ] else if (onRetry != null) ...[
              const SizedBox(height: 20),
              SGButton(
                label: 'Retry Connection',
                onPressed: onRetry,
                width: 220,
                height: 42,
                variant: SGButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
