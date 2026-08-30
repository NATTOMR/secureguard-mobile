import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'dashboard_card.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badgeLabel;
  final Widget? chartWidget;
  final int? criticalCount;
  final int? highCount;
  final int? mediumCount;
  final int? lowCount;

  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeLabel,
    this.chartWidget,
    this.criticalCount,
    this.highCount,
    this.mediumCount,
    this.lowCount,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (badgeLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badgeLabel!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 18),
          SizedBox(
            height: 170,
            child: chartWidget ?? _buildDefaultBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBarChart() {
    final c = (criticalCount ?? 3).toDouble();
    final h = (highCount ?? 12).toDouble();
    final m = (mediumCount ?? 24).toDouble();
    final l = (lowCount ?? 58).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (l * 1.2).clamp(10, 100),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 20,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Crit', style: TextStyle(fontSize: 11, color: AppColors.critical, fontWeight: FontWeight.bold)),
                    );
                  case 1:
                    return Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('High', style: TextStyle(fontSize: 11, color: AppColors.high, fontWeight: FontWeight.bold)),
                    );
                  case 2:
                    return Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Med', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.bold)),
                    );
                  case 3:
                    return Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Low', style: TextStyle(fontSize: 11, color: AppColors.low, fontWeight: FontWeight.bold)),
                    );
                  default:
                    return Text('');
                }
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (val) => FlLine(color: AppColors.cardBorder, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildBarGroup(0, c, AppColors.critical),
          _buildBarGroup(1, h, AppColors.high),
          _buildBarGroup(2, m, AppColors.warning),
          _buildBarGroup(3, l, AppColors.low),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 70,
            color: color.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
