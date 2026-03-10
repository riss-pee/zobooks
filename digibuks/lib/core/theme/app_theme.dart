import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Liquid Glass Palette: Warm Neutrals + Indigo
  static const Color primaryColor = Color(0xFF3949AB); // Indigo 600
  static const Color accentColor = Color(0xFFC5A059); // Muted Gold
  static const Color bgCream = Color(0xFFFFFBF0); // Warm Cream
  static const Color surfaceGlass = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color errorColor = Color(0xFFBA1A1A);

  // Legacy Aliases for backward compatibility
  static const Color secondaryColor = Colors.white;
  static const Color successColor = Color(0xFF2E7D32); // Green 800
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMuted;
  static const Color backgroundColor = bgCream;
  static const Color surfaceColor = surfaceGlass;

  static const Color surfaceGlassDark = Color(0xFF1E1E1E);
  static const Color textLight = Color(0xFFF7F0E0);
  static const Color textMutedLight = Color(0xFF9CA3AF);

  static ThemeData lightTheme = _buildTheme(Brightness.light);
  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    bool isDark = brightness == Brightness.dark;
    Color surface = isDark ? surfaceGlassDark : surfaceGlass;
    Color textPrimary = isDark ? textLight : textDark;
    Color textSecondary = isDark ? textMutedLight : textMuted;
    Color background = isDark ? const Color(0xFF0F1113) : bgCream;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: background,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: primaryColor,
              onPrimary: Colors.white,
              secondary: accentColor,
              surface: surfaceGlassDark,
              onSurface: textLight,
              error: errorColor,
            )
          : const ColorScheme.light(
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
          color: textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 30,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 14,
        ),
        titleSmall: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface.withAlpha(isDark ? 100 : 204),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
              color: Colors.white.withAlpha(isDark ? 20 : 77), width: 1.5),
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
        fillColor: surface.withAlpha(isDark ? 50 : 127),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: Colors.white.withAlpha(isDark ? 10 : 77), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor.withAlpha(102), width: 2),
        ),
      ),
    );
  }
}
