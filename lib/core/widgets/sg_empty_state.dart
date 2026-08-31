import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'sg_button.dart';

class SGEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SGEmptyState({
    super.key,
    this.title = 'No Data Available',
    this.description,
    this.subtitle,
    this.icon = Icons.shield_outlined,
    this.actionLabel,
    this.onAction,
  });

  String get effectiveDescription => description ?? subtitle ?? 'There are currently no items to display.';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(icon, size: 44, color: AppColors.textMuted),
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
              effectiveDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              SGButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 170,
                height: 42,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
