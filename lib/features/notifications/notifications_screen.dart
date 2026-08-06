import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: 'Security Alert Center',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationTile(
            title: 'Critical CVE Detected in Pipeline',
            body: 'CVE-2024-3094 was identified in auth-gateway-service container build.',
            time: '10m ago',
            isCritical: true,
          ),
          _buildNotificationTile(
            title: 'SIEM Alert: High Auth Failure Rate',
            body: 'IP 198.51.100.42 attempted 450 SSH connections in 60 seconds.',
            time: '32m ago',
            isCritical: true,
          ),
          _buildNotificationTile(
            title: 'Weekly Scan Schedule Completed',
            body: 'All 28 monitored repositories completed SAST static checks clean.',
            time: '2h ago',
            isCritical: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String body,
    required String time,
    required bool isCritical,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SGCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isCritical ? AppColors.critical : AppColors.primary).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCritical ? Icons.notifications_active_rounded : Icons.info_outline_rounded,
                color: isCritical ? AppColors.critical : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
