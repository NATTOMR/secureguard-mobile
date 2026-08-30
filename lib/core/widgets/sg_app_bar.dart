import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'sg_status_badge.dart';

class SGAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool showStatusBadge;
  final String statusText;
  final StatusType statusType;

  SGAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.actions,
    this.showStatusBadge = false,
    this.statusText = 'SYSTEM NORMAL',
    this.statusType = StatusType.normal,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton && Navigator.canPop(context)
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showStatusBadge) ...[
                SizedBox(width: 8),
                SGStatusBadge(label: statusText, type: statusType),
              ],
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.cardBorder,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
