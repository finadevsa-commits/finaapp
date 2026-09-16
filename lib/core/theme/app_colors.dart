import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Couleurs principales FINADEV ─────────────────────────────────────────
  static const Color primary       = Color(0xFF7B1514); // Rouge bordeaux FINADEV
  static const Color primaryDark   = Color(0xFF5A0F0E); // Bordeaux foncé
  static const Color primaryLight  = Color(0xFF9E2726); // Bordeaux clair

  // ── Couleur secondaire (vert FINADEV) ────────────────────────────────────
  static const Color secondary     = Color(0xFF1A6B3C); // Vert FINADEV
  static const Color secondaryLight= Color(0xFF2E9B5A);

  // ── Couleur d'accentuation (or / ambre pour les actions) ─────────────────
  static const Color accent        = Color(0xFFC8962A); // Or FINADEV
  static const Color accentLight   = Color(0xFFE8B84B);

  // ── Fonds ────────────────────────────────────────────────────────────────
  static const Color background    = Color(0xFFF5F5F7); // Fond général (gris très clair)
  static const Color surface       = Color(0xFFFFFFFF); // Cards blanches
  static const Color surfaceDark   = Color(0xFF0F2D45); // Header sombre (inspiré MoMo)

  // ── Textes ───────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E); // Texte principal
  static const Color textSecondary = Color(0xFF6B7280); // Texte secondaire
  static const Color textLight     = Color(0xFFFFFFFF); // Texte sur fond sombre
  static const Color textHint      = Color(0xFFB0B8C1); // Placeholder

  // ── États ────────────────────────────────────────────────────────────────
  static const Color success       = Color(0xFF16A34A); // Vert succès
  static const Color error         = Color(0xFFDC2626); // Rouge erreur
  static const Color warning       = Color(0xFFF59E0B); // Orange avertissement
  static const Color info          = Color(0xFF2563EB); // Bleu info

  // ── Opérations financières ───────────────────────────────────────────────
  static const Color credit        = Color(0xFF16A34A); // Entrée d'argent
  static const Color debit         = Color(0xFFDC2626); // Sortie d'argent

  // ── Utilitaires ──────────────────────────────────────────────────────────
  static const Color divider       = Color(0xFFE5E7EB);
  static const Color shadow        = Color(0x1A000000);
  static const Color overlay       = Color(0x80000000);
  static const Color shimmerBase   = Color(0xFFE0E0E0);
  static const Color shimmerHigh   = Color(0xFFF5F5F5);
}