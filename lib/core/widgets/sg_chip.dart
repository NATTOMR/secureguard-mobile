import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SGChipVariant { critical, high, medium, warning, low, success, info }

class SGChip extends StatelessWidget {
  final String label;
  final SGChipVariant variant;
  final IconData? icon;

  const SGChip({
    super.key,
    required this.label,
    this.variant = SGChipVariant.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (variant) {
      case SGChipVariant.critical:
        color = AppColors.critical;
        break;
      case SGChipVariant.high:
        color = AppColors.high;
        break;
      case SGChipVariant.medium:
      case SGChipVariant.warning:
        color = AppColors.warning;
        break;
      case SGChipVariant.low:
        color = AppColors.low;
        break;
      case SGChipVariant.success:
        color = AppColors.success;
        break;
      case SGChipVariant.info:
        color = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
