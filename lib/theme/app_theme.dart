import 'package:flutter/material.dart';

/// Design tokens and Material 3 theme configuration matching the luxury midnight dark-blue aesthetic.
class AppTheme {
  // Luxury Midnight Dark Blue Coffee Palette
  static const Color darkBackground = Color(0xFF0A1220); // Deep Midnight Blue / Sapphire Noir
  static const Color cardSurface = Color(0xFF142034);    // Rich Slate Navy Card Surface
  static const Color cardBorder = Color(0xFF22344E);     // Refined Slate-Blue Border
  static const Color imageBackdrop = Color(0xFFBDD8EB);  // Signature Soft Ice-Blue Backdrop
  static const Color goldAccent = Color(0xFFE5B96E);     // Warm Amber Champagne Gold
  static const Color caramelAccent = Color(0xFFDCA66A);  // Warm Honey Caramel
  static const Color lightCaramel = Color(0xFFF3DEC4);   // Cream Gold
  static const Color textWhite = Color(0xFFF8FAFC);      // Crisp Off-White / Slate Light
  static const Color textMuted = Color(0xFF94A3B8);      // Elegant Slate-Blue Gray
  static const Color subtleBorder = Color(0xFF1B2B44);   // Divider & Outline
  static const Color successGreen = Color(0xFF34D399);   // Mint Emerald
  static const Color warningOrange = Color(0xFFFBBF24);  // Warm Amber

  // Backward-compatible aliases mapped to the dark-blue luxury theme
  static const Color primaryCoffee = goldAccent;
  static const Color darkEspresso = darkBackground;
  static const Color creamBackground = darkBackground;
  static const Color surfaceWhite = cardSurface;
  static const Color textDark = textWhite;

  /// Dark-blue luxury theme for arCUPs application
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: goldAccent,
        secondary: caramelAccent,
        surface: cardSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textWhite,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textWhite,
          side: const BorderSide(color: Color(0xFF2E4566), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),
    );
  }
}
