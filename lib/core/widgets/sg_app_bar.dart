import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'sg_status_badge.dart';

class SGAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool showStatusBadge;
  final String statusText;
  final StatusType statusType;

  const SGAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
              onPressed: () => Navigator.maybePop(context),
            )
          : null,
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          if (showStatusBadge) ...[
            const SizedBox(width: 12),
            SGStatusBadge(label: statusText, type: statusType),
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
