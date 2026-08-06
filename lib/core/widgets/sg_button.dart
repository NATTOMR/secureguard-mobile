import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SGButtonVariant { primary, secondary, outline, danger, github }

class SGButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SGButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double height;

  const SGButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SGButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 54.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case SGButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        break;
      case SGButtonVariant.secondary:
        bgColor = AppColors.surface;
        fgColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.cardBorder);
        break;
      case SGButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.cardBorder, width: 1.5);
        break;
      case SGButtonVariant.danger:
        bgColor = AppColors.critical;
        fgColor = Colors.white;
        break;
      case SGButtonVariant.github:
        bgColor = const Color(0xFF24292F);
        fgColor = Colors.white;
        borderSide = const BorderSide(color: Color(0xFF444C56));
        break;
    }

    Widget childWidget;
    if (isLoading) {
      childWidget = SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    } else {
      childWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fgColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: variant == SGButtonVariant.primary ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppColors.cardBorderRadius,
            side: borderSide,
          ),
        ),
        child: childWidget,
      ),
    );
  }
}
