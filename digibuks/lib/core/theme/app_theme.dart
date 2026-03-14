import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Palette: Liquid Glass Theme
  static const Color primaryColorLight = Color(0xFF2E4032); // Muted Deep Forest Green
  static const Color primaryColorDark = Color(0xFFFFFFFF); // White
  
  static const Color accentColorLight = Color(0xFFD4AF37); // Gold
  static const Color accentColorDark = Color(0xFFD4D4D4);

  static const Color bgLight = Color(0xFFF7F8F6); // Very subtle green-tinted off-white
  static const Color bgDark = Color(0xFF0A0F0B); // Deep Forest Black
  static const Color surfaceDark = Color(0xFF161D18); // Dark Forest Charcoal
  
  static const Color textDark = Color(0xFF1A241D); // Dark green-black text
  static const Color textLight = Color(0xFFE2E8E4); // Minted White for dark mode text
  static const Color textMutedDark = Color(0xFF6C757D); // Softer muted text
  static const Color textMutedLight = Color(0xFFD4D4D4); 

  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF2E7D32);

  // Legacy Aliases for backward compatibility
  static const Color primaryColor = primaryColorLight; // Default to light primary
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
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(color: textDark, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      displayMedium: GoogleFonts.outfit(color: textDark, fontSize: 30, fontWeight: FontWeight.w600),
      displaySmall: GoogleFonts.outfit(color: textDark, fontSize: 24, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.outfit(color: textDark, fontSize: 24, fontWeight: FontWeight.w500),
      titleLarge: GoogleFonts.outfit(color: textDark, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.outfit(color: textDark, fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.outfit(color: textDark, fontSize: 14, fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.outfit(color: textDark, fontSize: 16, height: 1.5),
      bodyMedium: GoogleFonts.outfit(color: textDark, fontSize: 14),
      bodySmall: GoogleFonts.outfit(color: textMutedDark, fontSize: 12),
      labelMedium: GoogleFonts.outfit(color: textMutedDark, fontSize: 12),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textDark),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 2, // Softer drop shadow
      shadowColor: Colors.black.withAlpha(15),
      color: Colors.white, // Clean white for cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withAlpha(50), width: 1.0), // Very subtle, soft border
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorLight,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.black.withAlpha(25),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: textMutedDark, fontWeight: FontWeight.normal),
      labelStyle: const TextStyle(color: textDark, fontWeight: FontWeight.w500),
      prefixIconColor: textMutedDark,
      suffixIconColor: textMutedDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withAlpha(50), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withAlpha(50), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColorLight, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: const Color(0xFFD4AF37).withAlpha(40),
      indicatorShape: const StadiumBorder(
        side: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
      ),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(MaterialState.selected)) return const IconThemeData(color: Color(0xFFD4AF37));
        return const IconThemeData(color: Color(0xFFB3B3B3));
      }),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        if (states.contains(MaterialState.selected)) return const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12);
        return const TextStyle(color: Color(0xFFB3B3B3), fontWeight: FontWeight.normal, fontSize: 12);
      }),
    ),
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
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(color: textLight, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -0.5),
      displayMedium: GoogleFonts.outfit(color: textLight, fontSize: 30, fontWeight: FontWeight.w600),
      displaySmall: GoogleFonts.outfit(color: textLight, fontSize: 24, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.outfit(color: textLight, fontSize: 24, fontWeight: FontWeight.w500),
      titleLarge: GoogleFonts.outfit(color: textLight, fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.outfit(color: textLight, fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.outfit(color: textLight, fontSize: 14, fontWeight: FontWeight.bold),
      bodyLarge: GoogleFonts.outfit(color: textLight, fontSize: 16, height: 1.5),
      bodyMedium: GoogleFonts.outfit(color: textLight, fontSize: 14),
      bodySmall: GoogleFonts.outfit(color: textMutedLight, fontSize: 12),
      labelMedium: GoogleFonts.outfit(color: textMutedLight, fontSize: 12),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textLight),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      shadowColor: Colors.black.withAlpha(70),
      color: Colors.white.withAlpha(20), // Frosted transparency effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFB3B3B3), width: 0.5), // Thin glowing border
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorDark,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: Colors.black.withAlpha(70),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withAlpha(20),
      hintStyle: const TextStyle(color: textMutedLight, fontWeight: FontWeight.normal),
      labelStyle: const TextStyle(color: textLight, fontWeight: FontWeight.w500),
      prefixIconColor: textMutedLight,
      suffixIconColor: textMutedLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB3B3B3), width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFB3B3B3), width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColorDark, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: const Color(0xFFD4AF37).withAlpha(40),
      indicatorShape: const StadiumBorder(
        side: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
      ),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(MaterialState.selected)) return const IconThemeData(color: Color(0xFFD4AF37));
        return const IconThemeData(color: Color(0xFFD4D4D4));
      }),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        if (states.contains(MaterialState.selected)) return const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12);
        return const TextStyle(color: Color(0xFFD4D4D4), fontWeight: FontWeight.normal, fontSize: 12);
      }),
    ),
  );
}


