import 'package:flutter/material.dart';

/// Corner radii tokens.
abstract class AppRadii {
  static const double control = 12.0;
  static const double button = 16.0;
  static const double row = 16.0;
  static const double card = 20.0;
  static const double chip = 999.0;

  static const BorderRadius controlRadius =
      BorderRadius.all(Radius.circular(control));
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(button));
  static const BorderRadius rowRadius = BorderRadius.all(Radius.circular(row));
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius chipRadius =
      BorderRadius.all(Radius.circular(chip));
}
