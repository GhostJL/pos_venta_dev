import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Base Palette
  static const Color background = Color(0xFFF9F9F6);
  static const Color primary = Color(0xFF5A7F76);
  static const Color secondary = Color(0xFFA3B9AE);
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF7A8C8F);
  static const Color borders = Color(0xFFD8D8D8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF2F2F0);
  static const Color error = Color(0xFFC75C5C);
  static const Color success = Color(0xFF5C9C75);
  static const Color disabled = Color(0xFFCFCFCF);

  //  ThemeData
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      error: error,
      surface: cardBackground,
      onPrimary: Colors.white,
      onSecondary: textPrimary,
      onError: Colors.white,
      onSurface: textPrimary,
    ),

    // 📝 Typography
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.lato(
        fontSize: 16,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        color: textSecondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // 🔵 AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    ),

    // ✅ Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shadowColor: primary.withAlpha(40),
        elevation: 8,
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    // 🧾 Input Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBackground,
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: GoogleFonts.lato(color: textSecondary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),

    // 📦 Card Theme
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 4,
      shadowColor: textPrimary.withAlpha(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // 🧭 Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      elevation: 10,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
