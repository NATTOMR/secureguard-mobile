import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDark = true;

  // Enterprise Brand Palette (Always consistent)
  static const Color primary = Color(0xFF2563EB);    // Royal Blue
  static const Color secondary = Color(0xFF1D4ED8);  // Deep Blue

  // Status & Severity Colors
  static const Color success = Color(0xFF22C55E);   // Emerald Green / Passed
  static const Color warning = Color(0xFFF59E0B);   // Amber / Medium Severity
  static const Color critical = Color(0xFFEF4444);  // Bright Red / Critical Severity
  static const Color high = Color(0xFFF97316);      // Orange / High Severity
  static const Color low = Color(0xFF3B82F6);       // Blue / Low Severity
  static const Color info = Color(0xFF06B6D4);      // Cyan / Information

  // Dynamic Theme-Aware Palette
  static Color get background => isDark ? const Color(0xFF020817) : const Color(0xFFF8FAFC);
  static Color get surface => isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
  static Color get card => isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  static Color get cardBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  // Dynamic Typography
  static Color get textPrimary => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // Dynamic Gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient criticalGradient = const LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGlassGradient => isDark
      ? const LinearGradient(
          colors: [Color(0x1A2563EB), Color(0x050F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : const LinearGradient(
          colors: [Color(0x1A2563EB), Color(0x0A2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

  // Border Radius Token
  static const double borderRadius = 20.0;
  static final BorderRadius cardBorderRadius = BorderRadius.circular(borderRadius);
}
