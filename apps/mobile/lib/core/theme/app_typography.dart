import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale tokens as specified in design/spec.md.
abstract class AppTypography {
  static const String fontLatin = 'Plus Jakarta Sans';
  static const String fontUrdu = 'Noto Nastaliq Urdu';

  // Number / Display Large (34 sp / 800)
  static const TextStyle numberLarge = TextStyle(
    fontFamily: fontLatin,
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    height: 1.15,
  );

  // Screen Title (28 sp / 800)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontLatin,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.20,
  );

  // Section / Modal Heading (20 sp / 800)
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontLatin,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // Dish Heading (18 sp / 700)
  static const TextStyle heading = TextStyle(
    fontFamily: fontLatin,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.30,
  );

  // Card / Subheading (16 sp / 700)
  static const TextStyle subheading = TextStyle(
    fontFamily: fontLatin,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  // Standard Body (15 sp / 500)
  static const TextStyle body = TextStyle(
    fontFamily: fontLatin,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  // Strong Body (15 sp / 700)
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontLatin,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.45,
  );

  // Caption (13 sp / 400-500)
  static const TextStyle caption = TextStyle(
    fontFamily: fontLatin,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.40,
  );

  // Strong Caption (13 sp / 700)
  static const TextStyle captionStrong = TextStyle(
    fontFamily: fontLatin,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.40,
  );

  // Micro / Badge (12 sp / 600-700)
  static const TextStyle micro = TextStyle(
    fontFamily: fontLatin,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.30,
  );

  // Urdu Food Title / Subtitle
  static const TextStyle urduSubtitle = TextStyle(
    fontFamily: fontUrdu,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.90, // Generous line height prevents diacritic clipping in Nastaliq
  );
}
