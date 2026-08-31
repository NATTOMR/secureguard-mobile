import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const SGAppBar(
        title: AppStrings.reports,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Executive Report',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            SGCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Compliance Framework',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SGChip(label: 'SOC 2 Type II', variant: SGChipVariant.info),
                      SGChip(label: 'ISO 27001', variant: SGChipVariant.success),
                      SGChip(label: 'HIPAA Compliance', variant: SGChipVariant.medium),
                      SGChip(label: 'PCI-DSS v4.0', variant: SGChipVariant.low),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SGButton(
                    label: 'Export PDF Audit Summary',
                    icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generating PDF Report... Download will start automatically.')),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 28),

            Text(
              'Recent Generated Audit Logs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildReportTile(context, 'Q3 Executive Security Audit', 'SOC 2 Type II', 'PDF', '4.2 MB'),
            _buildReportTile(context, 'Weekly Vulnerability CVE Audit', 'Vulnerabilities', 'CSV', '1.1 MB'),
            _buildReportTile(context, 'Container Infrastructure Compliance', 'ISO 27001', 'JSON', '840 KB'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, String title, String category, String format, String size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SGCard(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloading $title ($format)...')),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('$category • $size', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            SGChip(label: format, variant: SGChipVariant.info),
          ],
        ),
      ),
    );
  }
}
