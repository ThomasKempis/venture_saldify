import 'package:flutter/material.dart';

class SmxColors {
  const SmxColors._();

  static const brandPrimary = Color(0xFF1B5E20);
  static const brandSecondary = Color(0xFF0D47A1);
  static const brandAccent = Color(0xFF58D9A4);
  static const brandLegacy = Color(0xFFD47B13);

  static const navigationDark = Color(0xFF102D36);
  static const textDark = Color(0xFF173144);
  static const iconDark = Color(0xFF172431);
  static const textMuted = Color(0xFF667783);

  static const surfaceQr = Color(0xFFF7FBFF);
  static const surfacePill = Color(0xFFE8F5F0);
  static const surfaceData = Color(0xFFF4F8FB);

  static const successBackground = Color(0xFFE7F8F0);
  static const successForeground = Color(0xFF1B8A54);
  static const warningBackground = Color(0xFFFFF4D8);
  static const warningForeground = Color(0xFF9C6800);
  static const dangerBackground = Color(0xFFFFE7E7);
  static const dangerForeground = Color(0xFFB42318);
  static const alertBackground = Color(0xFFFFF3D6);
  static const alertForeground = Color(0xFF9A5B00);

  static const white = Colors.white;
  static const white70 = Colors.white70;
  static const white54 = Colors.white54;
  static const white38 = Colors.white38;
  static const white24 = Colors.white24;
  static const black = Colors.black;
  static const transparent = Colors.transparent;

  static Color whiteAlpha(double alpha) => white.withValues(alpha: alpha);
  static Color blackAlpha(double alpha) => black.withValues(alpha: alpha);
  static Color accentAlpha(double alpha) =>
      brandAccent.withValues(alpha: alpha);
}

class SmxGradients {
  const SmxGradients._();

  static const saldifyBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [SmxColors.brandPrimary, SmxColors.brandSecondary],
  );
}
