import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum StatusType { normal, warning, critical }

class SGStatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;

  const SGStatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.normal,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (type) {
      case StatusType.normal:
        badgeColor = AppColors.success;
        break;
      case StatusType.warning:
        badgeColor = AppColors.warning;
        break;
      case StatusType.critical:
        badgeColor = AppColors.critical;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: badgeColor,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
