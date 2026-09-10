import 'package:flutter/material.dart';

class AgriColors {
  // Main Greens (Slightly darkened, rich botanical agricultural palette)
  static const Color headerGreen = Color(0xFF5A9B26); // Rich natural green
  static const Color primaryGreen = Color(0xFF5A9B26);
  static const Color lightGreenBtn = Color(0xFF67A82E);
  static const Color darkOliveBtn = Color(0xFF233612); // Dark olive button / floating action button
  static const Color darkOliveText = Color(0xFF1E293B);

  // Category Pastel Backgrounds
  static const Color categorySayuranBg = Color(0xFFCEECD4);
  static const Color categoryBuahBg = Color(0xFFFBDDCF);
  static const Color categoryPalawijaBg = Color(0xFFFDEBBF);
  static const Color categoryKacangBg = Color(0xFFCEEEF3);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF3F7EF);
  static const Color scaffoldBg = Color(0xFF50891F);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color lightSageBg = Color(0xFFF0F5EC);
  static const Color badgeGreenBg = Color(0xFFE4F4DD);
  static const Color badgeRedBg = Color(0xFFFDE8E8);
  static const Color cardBorder = Color(0xFFE0E7DE);
  static const Color inputBorder = Color(0xFFCAD4C8);

  // Modern Accents & Dark Greens
  static const Color primaryDark = Color(0xFF1D2F0E);
  static const Color accentGreen = Color(0xFF32751B);

  // Text colors
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status colors
  static const Color verifiedGreen = Color(0xFF246C19);
  static const Color rejectedRed = Color(0xFFE53935);
  static const Color badgeRedText = Color(0xFFDC2626);
  static const Color pendingOrange = Color(0xFFF59E0B);
  static const Color starGold = Color(0xFFFFB300);

  // Organic Tone Gradients (Rich botanical multi-stop gradients)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF74B830), // Vibrant lush highlight
      Color(0xFF579624), // Rich body agricultural green
      Color(0xFF3F7517), // Deep grounded emerald-olive
    ],
    stops: [0.0, 0.52, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF72B42E),
      Color(0xFF4F8D1D),
    ],
  );

  static const LinearGradient accentGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4E9324),
      Color(0xFF2D6913),
    ],
  );

  static const LinearGradient darkOliveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF364F1D),
      Color(0xFF1D2C0E),
    ],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF5350),
      Color(0xFFD32F2F),
    ],
  );

  static const LinearGradient surfaceCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF6FAF2),
    ],
  );

  static const LinearGradient sageCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8FBF5),
      Color(0xFFE8F2E1),
    ],
  );

  static const LinearGradient badgeGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE6F6DF),
      Color(0xFFCEECCA),
    ],
  );

  // Category Pastel Gradients
  static const LinearGradient categorySayuranGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0F7E6), Color(0xFFBEE8C9)],
  );

  static const LinearGradient categoryBuahGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFEFE9), Color(0xFFFBD2C1)],
  );

  static const LinearGradient categoryPalawijaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF6E1), Color(0xFFFEE2AF)],
  );

  static const LinearGradient categoryKacangGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE5F8FB), Color(0xFFBFEBF2)],
  );

  // Soft Ambient Shadow Presets
  static const List<BoxShadow> softCardShadow = [
    BoxShadow(
      color: Color(0x0E1E293B),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x06233612),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> elevatedCardShadow = [
    BoxShadow(
      color: Color(0x161E293B),
      blurRadius: 18,
      offset: Offset(0, 6),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x0B233612),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> buttonShadowPrimary = [
    BoxShadow(
      color: Color(0x42559020),
      blurRadius: 14,
      offset: Offset(0, 5),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonShadowDark = [
    BoxShadow(
      color: Color(0x3B1E2D0E),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}


