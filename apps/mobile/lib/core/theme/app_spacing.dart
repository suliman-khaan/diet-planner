import 'package:flutter/material.dart';

/// 4 dp base grid spacing tokens.
/// Adheres strictly to design/spec.md and design rules.
abstract class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double hero = 48.0;

  // Directional EdgeInsets (RTL safe)
  static const EdgeInsetsDirectional screenPadding = EdgeInsetsDirectional.only(
    start: md,
    end: md,
    top: lg,
    bottom: xl,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingLoose = EdgeInsets.all(lg);
  static const EdgeInsets rowPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}
