import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/report_pdf_service.dart';
import '../../core/widgets/widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFramework = 'SOC 2 Type II';
  bool _isGenerating = false;

  final List<String> _frameworks = [
    'SOC 2 Type II',
    'ISO 27001',
    'HIPAA Compliance',
    'PCI-DSS v4.0',
  ];

  Future<void> _handleExportPdf({String? framework, String? title}) async {
    final targetFramework = framework ?? _selectedFramework;
    final targetTitle = title ?? 'Executive Security Audit ($targetFramework)';

    setState(() => _isGenerating = true);
    try {
      await ReportPdfService.exportAndPreviewReport(
        framework: targetFramework,
        reportTitle: targetTitle,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppColors.critical,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _frameworks.map((fw) {
                      final isSelected = _selectedFramework == fw;
                      return ChoiceChip(
                        label: Text(fw),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedFramework = fw);
                          }
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.25),
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SGButton(
                    label: _isGenerating ? 'Rendering Vector PDF...' : 'Export PDF Audit Summary',
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                    onPressed: _isGenerating ? null : () => _handleExportPdf(),
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

            _buildReportTile(
              context,
              'Q3 Executive Security Audit',
              'SOC 2 Type II',
              'PDF',
              '4.2 MB',
              onTap: () => _handleExportPdf(
                framework: 'SOC 2 Type II',
                title: 'Q3 Executive Security Audit',
              ),
            ),
            _buildReportTile(
              context,
              'Weekly Vulnerability CVE Audit',
              'ISO 27001',
              'PDF',
              '1.8 MB',
              onTap: () => _handleExportPdf(
                framework: 'ISO 27001',
                title: 'Weekly Vulnerability CVE Audit',
              ),
            ),
            _buildReportTile(
              context,
              'Cloud Infrastructure Compliance',
              'PCI-DSS v4.0',
              'PDF',
              '2.4 MB',
              onTap: () => _handleExportPdf(
                framework: 'PCI-DSS v4.0',
                title: 'Cloud Infrastructure Compliance',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context,
    String title,
    String category,
    String format,
    String size, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SGCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('$category • Tap to Open / Share', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
