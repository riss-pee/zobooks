import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Palette: Grey + Black
  static const Color primaryColor = Color(0xFF3949AB); // Indigo 600
  static const Color accentColor = Color(0xFFC5A059);  // Muted Gold
  static const Color bgCream = Color(0xFFF5F5F5);      // Light Grey
  static const Color surfaceGlass = Color(0xFFFFFFFF);
  static const Color textDark = Colors.black;
  static const Color textMuted = Color(0xFF6B7280);
  static const Color errorColor = Color(0xFFBA1A1A);

  // Legacy Aliases for backward compatibility
  static const Color secondaryColor = Colors.white;
  static const Color successColor = Color(0xFF2E7D32); // Green 800
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;
  static const Color backgroundColor = bgCream;
  static const Color surfaceColor = surfaceGlass;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgCream,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.white,
      surface: surfaceGlass,
      onSurface: textDark,
      error: errorColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        color: textDark,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        color: textDark,
        fontSize: 30,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.outfit(
        color: textDark,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.outfit(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.outfit(
        color: textDark,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: GoogleFonts.outfit(
        color: textDark,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        color: textMuted,
        fontSize: 14,
      ),
      labelMedium: GoogleFonts.outfit(
        color: textMuted,
        fontSize: 12,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textDark),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white.withAlpha(204),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withAlpha(77), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.normal),
      labelStyle: const TextStyle(color: textDark, fontWeight: FontWeight.w500),
      prefixIconColor: textMuted,
      suffixIconColor: textMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: textDark.withAlpha(30), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor.withAlpha(102), width: 2),
      ),
    ),
  );

  static ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1113),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      surface: Color(0xFF1A1C1E),
      onSurface: Colors.white,
    ),
  );
}
