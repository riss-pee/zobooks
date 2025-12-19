import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // MD3-friendly neutral + Indigo / Blue accent
  // Chosen: Indigo 600 as primary, Indigo 400 as accent for highlights
  static const Color primaryColor = Color(0xFF3949AB); // Indigo 600
  static const Color secondaryColor = Color(0xFFFFFFFF); // white
  static const Color accentColor = Color(0xFF5C6BC0); // Indigo 400 (accent)
  static const Color backgroundColor = Color(0xFFFFFFFF); // white background for light theme
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF1F2937); // dark grey for subtle success
  static const Color textPrimary = Color(0xFF000000); // black text
  static const Color textSecondary = Color(0xFF6B7280); // medium grey

  // Gradient for primary backgrounds (used in Scaffold, cards, etc.)
  // No gradients: follow Material 3 principle — use solid surfaces and elevation

  // Light Theme – modern, glass‑morphism ready
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: secondaryColor,
      secondary: accentColor,
      onSecondary: secondaryColor,
      error: errorColor,
      surface: surfaceColor,
      // 'background' and 'onBackground' deprecated in M3 - prefer surface/onSurface
      // Keep the background color by setting the scaffoldBackgroundColor above
      onSurface: Color(0xFF0F1724),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: textSecondary,
        fontSize: 14,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      surfaceTintColor: surfaceColor,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Cards remain white on light theme with subtle elevation
      color: const Color(0xFFFFFFFF),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
  );

  // Dark Theme – deep, luxurious
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF0B0F12), // near-black for dark theme
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: secondaryColor,
      secondary: primaryColor,
      onSecondary: secondaryColor,
      error: errorColor,
      surface: Color(0xFF121212),
      // 'background' and 'onBackground' deprecated in M3 - prefer surface/onSurface
      onSurface: secondaryColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 34,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: Colors.grey,
        fontSize: 14,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white70),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      // Cards use a dark surface in dark theme
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    ),
  );
}

