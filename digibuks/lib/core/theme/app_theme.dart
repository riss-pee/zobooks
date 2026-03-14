import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Palette: Liquid Glass Theme
  static const Color primaryColorLight = Color(0xFF2E4032);
  static const Color primaryColorDark = Color(0xFFFFFFFF);

  static const Color accentColorLight = Color(0xFFD4AF37);
  static const Color accentColorDark = Color(0xFFD4D4D4);

  static const Color bgLight = Color(0xFFF7F8F6);
  static const Color bgDark = Color(0xFF0A0F0B);
  static const Color surfaceDark = Color(0xFF161D18);

  static const Color textDark = Color(0xFF1A241D);
  static const Color textLight = Color(0xFFE2E8E4);

  static const Color textMutedDark = Color(0xFF6C757D);
  static const Color textMutedLight = Color(0xFFD4D4D4);

  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF2E7D32);

  // Legacy Aliases
  static const Color primaryColor = primaryColorLight;
  static const Color secondaryColor = accentColorLight;
  static const Color accentColor = accentColorLight;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMutedDark;
  static const Color textMuted = textMutedDark;
  static const Color backgroundColor = bgLight;
  static const Color surfaceColor = Colors.white;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColorLight,
    scaffoldBackgroundColor: bgLight,
    colorScheme: const ColorScheme.light(
      primary: primaryColorLight,
      onPrimary: Colors.white,
      secondary: accentColorLight,
      onSecondary: textDark,
      surface: bgLight,
      onSurface: textDark,
      error: errorColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColorDark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColorDark,
      onPrimary: Colors.black,
      secondary: accentColorDark,
      onSecondary: primaryColorDark,
      surface: surfaceDark,
      onSurface: textLight,
      error: errorColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
  );
}
