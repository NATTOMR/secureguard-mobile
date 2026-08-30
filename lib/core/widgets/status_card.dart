import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/dashboard_model.dart';
import '../constants/app_colors.dart';
import 'dashboard_card.dart';

class StatusCard extends StatelessWidget {
  final List<SystemStatusModel> systemStatuses;

  const StatusCard({
    super.key,
    required this.systemStatuses,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Live Enterprise System Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'ALL SYSTEMS HEALTHY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: systemStatuses.map((status) {
                final isOk = status.status == 'operational';
                final color = isOk ? AppColors.success : AppColors.warning;

                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: color, blurRadius: 6, spreadRadius: 1),
                          ],
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.3, 1.3),
                            duration: 1000.ms,
                          ),
                      SizedBox(width: 8),
                      Text(
                        status.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${status.latencyMs}ms',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
