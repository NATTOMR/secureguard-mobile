import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SGAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double radius;
  final bool isOnline;

  const SGAvatar({
    super.key,
    this.imageUrl,
    this.initials = 'SG',
    this.radius = 24.0,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary,
          child: Text(
            initials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.7,
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
