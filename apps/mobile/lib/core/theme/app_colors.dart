import 'package:flutter/material.dart';

/// Design tokens for colors across light and dark themes.
/// Derived from design/spec.md and design/ui-concepts/StyleGuide.html.
abstract class AppColors {
  // --- Light Palette ---
  static const Color lightPrimary = Color(0xFF1D6A50);
  static const Color lightPrimarySoft = Color(0xFFE2EFE8);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF6F5F1);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFF0EFEA);
  static const Color lightBorder = Color(0xFFE4E2DA);
  static const Color lightBorderStrong = Color(0xFFDAD7CD);
  static const Color lightInk = Color(0xFF16201B);
  static const Color lightMuted = Color(0xFF56635C);

  // --- Dark Palette ---
  static const Color darkPrimary = Color(0xFF469E7F);
  static const Color darkPrimarySoft = Color(0xFF17382B);
  static const Color darkOnPrimary = Color(0xFF0E231B);
  static const Color darkBackground = Color(0xFF121614);
  static const Color darkSurface = Color(0xFF1A211D);
  static const Color darkSurfaceSecondary = Color(0xFF242C27);
  static const Color darkBorder = Color(0xFF2D3731);
  static const Color darkBorderStrong = Color(0xFF3E4B43);
  static const Color darkInk = Color(0xFFEDF3EF);
  static const Color darkMuted = Color(0xFF9CA9A2);

  // --- Ramadan Mode ---
  static const Color ramadanBackground = Color(0xFF233B5E);
  static const Color ramadanDarkBackground = Color(0xFF182840);
  static const Color ramadanSoft = Color(0xFFC9D6EA);
  static const Color ramadanBorder = Color(0xFF6C83A8);

  // --- Badges & Highlights ---
  static const Color familyPotBg = Color(0xFFFBE9CC);
  static const Color familyPotText = Color(0xFF7A4A10);
  static const Color familyPotDarkBg = Color(0xFF382613);
  static const Color familyPotDarkText = Color(0xFFF2C48E);

  static const Color reviewedText = Color(0xFF1D6A50);
  static const Color unreviewedBg = Color(0xFFF4EFEA);
  static const Color unreviewedText = Color(0xFF7A4A10);

  // --- Nutrients (Always paired with text labels) ---
  static const Color protein = Color(0xFF1D6A50);
  static const Color carbs = Color(0xFFD9822B);
  static const Color fat = Color(0xFF3B6DB3);
  static const Color fibre = Color(0xFF8A9A3C);

  // --- Planned / Dashed track ---
  static const Color plannedDash = Color(0xFFB9B6AA);
  static const Color plannedFill = Color(0xFF9CC7B4);
}
