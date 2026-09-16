
 import 'package:flutter/material.dart';
 import 'package:google_fonts/google_fonts.dart';
 import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display (grands titres) ───────────────────────────────────────────────
  static TextStyle display1 = GoogleFonts.dmSans(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle display2 = GoogleFonts.dmSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  // ── Titres ────────────────────────────────────────────────────────────────
  static TextStyle h1 = GoogleFonts.dmSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle h2 = GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle h3 = GoogleFonts.dmSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Corps ─────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ── Labels ────────────────────────────────────────────────────────────────
  static TextStyle labelLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ── Montants FCFA (style bancaire) ────────────────────────────────────────
  static TextStyle amountLarge = GoogleFonts.dmSans(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
    letterSpacing: -1,
  );

  static TextStyle amountMedium = GoogleFonts.dmSans(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ── Boutons ───────────────────────────────────────────────────────────────
  static TextStyle button = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );
}