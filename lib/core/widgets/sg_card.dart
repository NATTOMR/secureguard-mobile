import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SGCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;

  const SGCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final border = Border.all(
      color: borderColor ?? AppColors.cardBorder,
      width: 1,
    );

    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.card,
      borderRadius: AppColors.cardBorderRadius,
      border: border,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppColors.cardBorderRadius,
          splashColor: AppColors.primary.withOpacity(0.15),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: content,
        ),
      );
    }

    return content;
  }
}
