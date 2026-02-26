import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary ────────────────────────────────────────────────
  static const Color primary       = Color(0xFF1E1E1E);
  static const Color primaryLight  = Color(0xFF444444);

  // ── Accent ────────────────────────────────────────────────
  static const Color accent        = Color(0xFFEAA238); // Orange/gold price color
  static const Color accentBlue    = Colors.blueAccent;

  // ── Background ────────────────────────────────────────────
  static const Color background    = Color(0xFFF0F2F5);
  static const Color surface       = Colors.white;
  static const Color surfaceGrey   = Color(0xFFF3F5F7);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFFB0B7C3);

  // ── Status ────────────────────────────────────────────────
  static const Color success       = Color(0xFF22C55E);
  static const Color successLight  = Color(0xFFE6F8EC);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color error         = Color(0xFFEF4444);
  static const Color errorLight    = Color(0xFFFFEEEE);
  static const Color info          = Color(0xFF3B82F6);
  static const Color infoLight     = Color(0xFFEEF7FE);

  // ── Border ────────────────────────────────────────────────
  static const Color border        = Color(0xFFE5E7EB);
  static const Color borderDark    = Color(0xFFD1D5DB);

  // ── Overlay ───────────────────────────────────────────────
  static Color shadow              = Colors.black.withOpacity(0.07);
  static Color overlay             = Colors.black.withOpacity(0.4);

  // ── Property Type Tags ────────────────────────────────────
  static const Color boardingHouse = Color(0xFFFFF6E4);
  static const Color dorm          = Color(0xFFEEF7FE);
  static const Color apartment     = Color(0xFFE6F8EC);
  static const Color bedspace      = Color(0xFFF5F5F5);
}