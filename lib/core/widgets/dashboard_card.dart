import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DashboardCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? borderColor;
  final double? width;
  final double? height;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(
      color: widget.borderColor ?? AppColors.cardBorder,
      width: 1,
    );

    return AnimatedScale(
      scale: _isHovered ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.gradient == null ? (widget.backgroundColor ?? AppColors.card) : null,
          gradient: widget.gradient,
          borderRadius: AppColors.cardBorderRadius,
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.onTap != null
            ? InkWell(
                onTap: widget.onTap,
                onHighlightChanged: (isHighlight) {
                  setState(() {
                    _isHovered = isHighlight;
                  });
                },
                borderRadius: AppColors.cardBorderRadius,
                splashColor: AppColors.primary.withOpacity(0.15),
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}
