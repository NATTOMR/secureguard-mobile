import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'sg_button.dart';

class SGErrorView extends StatelessWidget {
  final String title;
  final String errorMessage;
  final VoidCallback onRetry;

  const SGErrorView({
    super.key,
    this.title = 'Security Service Error',
    required this.errorMessage,
    required this.onRetry,
  });

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
                color: AppColors.critical.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.critical.withOpacity(0.4)),
              ),
              child: const Icon(Icons.gpp_maybe_rounded, size: 48, color: AppColors.critical),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SGButton(
              label: 'Retry Request',
              onPressed: onRetry,
              width: 160,
              height: 44,
              variant: SGButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
