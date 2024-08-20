import 'package:flutter/material.dart';
import 'package:local_app/theme/lib_color_schemes.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    colorScheme: MaterialTheme.lightScheme()
  );
  static ThemeData dark = ThemeData(
      colorScheme: MaterialTheme.darkHighContrastScheme()
  );
}