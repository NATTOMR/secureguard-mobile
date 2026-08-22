import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'sg_card.dart';

class SGStatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? accentColor;
  final String? trendText;
  final bool isTrendPositive;
  final VoidCallback? onTap;

  const SGStatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.accentColor,
    this.trendText,
    this.isTrendPositive = true,
    this.onTap,
  });

  Color get effectiveColor => accentColor ?? iconColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return SGCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: effectiveColor.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: effectiveColor, size: 20),
              ),
              if (trendText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isTrendPositive ? AppColors.success : AppColors.critical).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 14,
                        color: isTrendPositive ? AppColors.success : AppColors.critical,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trendText!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isTrendPositive ? AppColors.success : AppColors.critical,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
