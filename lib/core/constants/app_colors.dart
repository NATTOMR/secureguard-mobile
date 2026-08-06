import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Enterprise Dark Palette
  static const Color primary = Color(0xFF2563EB);    // Royal Blue
  static const Color secondary = Color(0xFF1D4ED8);  // Deep Blue
  static const Color background = Color(0xFF020817); // Ultra-Dark Slate / Black
  static const Color surface = Color(0xFF0F172A);    // Dark Slate
  static const Color card = Color(0xFF1E293B);       // Elevated Dark Slate
  static const Color cardBorder = Color(0xFF334155); // Subtle Border Slate

  // Status & Severity Colors
  static const Color success = Color(0xFF22C55E);   // Emerald Green / Passed
  static const Color warning = Color(0xFFF59E0B);   // Amber / Medium Severity
  static const Color critical = Color(0xFFEF4444);  // Bright Red / Critical Severity
  static const Color high = Color(0xFFF97316);      // Orange / High Severity
  static const Color low = Color(0xFF3B82F6);       // Blue / Low Severity
  static const Color info = Color(0xFF06B6D4);      // Cyan / Information

  // Neutral & Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);   // Bright Off-White
  static const Color textSecondary = Color(0xFF94A3B8); // Cool Muted Gray
  static const Color textMuted = Color(0xFF64748B);     // Dim Subtext Gray

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient criticalGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    colors: [Color(0x1A2563EB), Color(0x050F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Border Radius Token
  static const double borderRadius = 20.0;
  static final BorderRadius cardBorderRadius = BorderRadius.circular(borderRadius);
}
