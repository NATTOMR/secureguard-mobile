import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'dashboard_card.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final Color? accentColor;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.color,
    this.accentColor,
    required this.onTap,
  });

  Color get effectiveColor => accentColor ?? color ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14.0),
      borderColor: effectiveColor.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: effectiveColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: effectiveColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
