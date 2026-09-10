import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AgriSmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const AgriSmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final secondaryCurvedAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.06, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.03, 0.0),
          ).animate(secondaryCurvedAnimation),
          child: child,
        ),
      ),
    );
  }
}

class AgriTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AgriColors.headerGreen,
      primaryColor: AgriColors.primaryGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AgriColors.primaryGreen,
        primary: AgriColors.primaryGreen,
        secondary: AgriColors.darkOliveBtn,
        surface: AgriColors.surfaceWhite,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.windows: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.linux: AgriSmoothPageTransitionsBuilder(),
        },
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: AgriColors.textMain,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: AgriColors.textMain,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: AgriColors.textMain,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: AgriColors.textMain,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: AgriColors.textMain,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: AgriColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AgriColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AgriColors.inputBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AgriColors.inputBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AgriColors.primaryGreen, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AgriColors.textHint,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F150B),
      primaryColor: AgriColors.primaryGreen,
      colorScheme: const ColorScheme.dark(
        primary: AgriColors.primaryGreen,
        secondary: Color(0xFF8CBF37),
        surface: Color(0xFF182212),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.windows: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.linux: AgriSmoothPageTransitionsBuilder(),
          TargetPlatform.fuchsia: AgriSmoothPageTransitionsBuilder(),
        },
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          color: const Color(0xFFF1F5E9),
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          color: const Color(0xFFF1F5E9),
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          color: const Color(0xFFF1F5E9),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          color: const Color(0xFFE2EAD8),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          color: const Color(0xFFE2EAD8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF9BAE8E),
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF182212),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E3D23), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2E3D23), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AgriColors.primaryGreen, width: 2),
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF75876A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
