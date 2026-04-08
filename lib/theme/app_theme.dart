import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Green Colors
  static const Color greenPrimary = Color(0xFF2BEE4B);
  static const Color greenBackgroundLight = Color(0xFFF6F8F6);
  static const Color greenBackgroundDark = Color(0xFF102213);

  // Classic Blue Colors
  static const Color bluePrimary = Color(0xFF2196F3);
  static const Color blueBackgroundLight = Color(0xFFF5F7FA);
  static const Color blueBackgroundDark = Color(0xFF0D1B2A);

  static ThemeData get modernGreenLight {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: greenBackgroundLight,
      colorScheme: base.colorScheme.copyWith(
        primary: greenPrimary,
        onPrimary: const Color(0xFF0D1B10),
        secondary: const Color(0xFF9EFFAE),
        surface: Colors.white,
        onSurface: const Color(0xFF0D1B10),
      ),
      textTheme: GoogleFonts.lexendTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.notoSans(
          textStyle: base.textTheme.bodyMedium,
          color: const Color(0xFF0D1B10),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get modernGreenDark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: greenBackgroundDark,
      colorScheme: base.colorScheme.copyWith(
        primary: greenPrimary,
        onPrimary: const Color(0xFF0D1B10),
        secondary: const Color(0xFF1FCC39),
        surface: const Color(0xFF1A2E1C),
        onSurface: Colors.white,
        shadow: Colors.black,
      ),
      cardColor: const Color(0xFF1A2E1C),
      dividerColor: const Color(0xFF2D4A30),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      textTheme: GoogleFonts.lexendTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.notoSans(
          textStyle: base.textTheme.bodyMedium,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get classicBlueLight {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: blueBackgroundLight,
      colorScheme: base.colorScheme.copyWith(
        primary: bluePrimary,
        onPrimary: Colors.white,
        secondary: Colors.blueAccent,
        surface: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
      ),
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
        // Changed font for Classic look
        bodyMedium: GoogleFonts.roboto(
          textStyle: base.textTheme.bodyMedium,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get classicBlueDark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: blueBackgroundDark,
      colorScheme: base.colorScheme.copyWith(
        primary: bluePrimary,
        onPrimary: Colors.white,
        secondary: const Color(0xFF64B5F6),
        surface: const Color(0xFF1A2332),
        onSurface: Colors.white,
        shadow: Colors.black,
      ),
      cardColor: const Color(0xFF1A2332),
      dividerColor: const Color(0xFF2D3E52),
      shadowColor: Colors.black.withValues(alpha: 0.3),
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.roboto(
          textStyle: base.textTheme.bodyMedium,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
