import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Color
  static const Color primary = Color(0xFF6750A4);
  static const Color secondary = Color(0xFF625B71);

  // Transparency Scale (Primary with opacities)
  static final Map<int, Color> primaryOpacity = {
    100: primary,
    80: primary.withAlpha((255 * 0.8).round()),
    60: primary.withAlpha((255 * 0.6).round()),
    40: primary.withAlpha((255 * 0.4).round()),
    20: primary.withAlpha((255 * 0.2).round()),
    10: primary.withAlpha((255 * 0.1).round()),
  };

  // Grayscale Scale
  static const Map<int, Color> greyScale = {
    900: Color(0xFF1C1B1F),
    800: Color(0xFF313033),
    700: Color(0xFF484649),
    600: Color(0xFF605D62),
    500: Color(0xFF79747E),
    400: Color(0xFF938F99),
    300: Color(0xFFAEA9B4),
    200: Color(0xFFCAC4D0),
    100: Color(0xFFE6E1E5),
    50: Color(0xFFFEF7FF),
  };

  // Status Colors
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
}
