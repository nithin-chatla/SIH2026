import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────────────────────────
  // Premium Light Mode Palette (Government Enterprise Grade)
  // ─────────────────────────────────────────────────────────────

  // Canvas & Surface System
  static const Color background = Color(0xFFF7F8FC);       // Cool gray canvas
  static const Color surface = Color(0xFFFFFFFF);           // Pure White (Cards)
  static const Color surfaceElevated = Color(0xFFF1F4F9);   // Elevated inputs/badges
  static const Color surfaceLight = Color(0xFFE8ECF4);      // Secondary surface
  static const Color surfaceDark = Color(0xFF0B1120);       // Dark surface (headers/drawers)

  // Border System
  static const Color border = Color(0xFFE1E6EF);            // Standard border
  static const Color borderSubtle = Color(0xFFCBD3E1);      // Emphasized border
  static const Color borderLight = Color(0xFFF1F5F9);       // Faint border
  static const Color borderFocus = Color(0xFF3B82F6);       // Focus state

  // ─────────────────────────────────────────────────────────────
  // Primary Brand (Deep Ocean Blue)
  // ─────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A6FEF);           // Hero Blue
  static const Color primaryDark = Color(0xFF1557C0);        // Pressed state
  static const Color primaryLight = Color(0xFF4A90F5);       // Hover state
  static const Color primarySurface = Color(0xFFEBF3FF);     // Blue 50 tint
  static const Color primaryGradientStart = Color(0xFF1A6FEF);
  static const Color primaryGradientEnd = Color(0xFF0D47A1);

  // Secondary Accents
  static const Color teal = Color(0xFF0D9488);              // Teal 600
  static const Color indigo = Color(0xFF4F46E5);            // Indigo 600

  // ─────────────────────────────────────────────────────────────
  // Risk Classification Colors (Disaster Management Scale)
  // ─────────────────────────────────────────────────────────────
  static const Color safeGreen = Color(0xFF059669);         // Emerald 600
  static const Color safeGreenBg = Color(0xFFECFDF5);       // Emerald 50
  static const Color safeGreenBorder = Color(0xFFA7F3D0);   // Emerald 200

  static const Color advisoryYellow = Color(0xFFD97706);    // Amber 600
  static const Color advisoryYellowBg = Color(0xFFFFFBEB);  // Amber 50
  static const Color advisoryYellowBorder = Color(0xFFFDE68A);

  static const Color warningOrange = Color(0xFFEA580C);     // Orange 600
  static const Color warningOrangeBg = Color(0xFFFFF7ED);   // Orange 50
  static const Color warningOrangeBorder = Color(0xFFFED7AA);

  static const Color criticalRed = Color(0xFFDC2626);       // Red 600
  static const Color criticalRedBg = Color(0xFFFEF2F2);     // Red 50
  static const Color criticalRedBorder = Color(0xFFFECACA);

  // ─────────────────────────────────────────────────────────────
  // Sensor Metric Accents
  // ─────────────────────────────────────────────────────────────
  static const Color rainBlue = Color(0xFF0284C7);          // Sky 600
  static const Color soilAmber = Color(0xFFD97706);         // Amber 600
  static const Color slopePurple = Color(0xFF7C3AED);       // Violet 600
  static const Color riverCyan = Color(0xFF0891B2);         // Cyan 600

  // ─────────────────────────────────────────────────────────────
  // Typography (High-Contrast Slate)
  // ─────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0B1120);       // Near-black
  static const Color textSecondary = Color(0xFF475569);     // Slate 600
  static const Color textMuted = Color(0xFF94A3B8);         // Slate 400
  static const Color textOnDark = Color(0xFFF1F5F9);        // On dark bg
  static const Color textOnPrimary = Color(0xFFFFFFFF);     // On primary

  // ─────────────────────────────────────────────────────────────
  // 5-Level Warning Palette
  // ─────────────────────────────────────────────────────────────
  static const Color level1Green = Color(0xFF059669);
  static const Color level1GreenBg = Color(0xFFECFDF5);
  static const Color level2Blue = Color(0xFF0284C7);
  static const Color level2BlueBg = Color(0xFFF0F9FF);
  static const Color level3Yellow = Color(0xFFD97706);
  static const Color level3YellowBg = Color(0xFFFFFBEB);
  static const Color level4Orange = Color(0xFFEA580C);
  static const Color level4OrangeBg = Color(0xFFFFF7ED);
  static const Color level5Red = Color(0xFFDC2626);
  static const Color level5RedBg = Color(0xFFFEF2F2);

  // ─────────────────────────────────────────────────────────────
  // Premium Gradients
  // ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A6FEF), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0B1120), Color(0xFF162036)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardShimmer = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient criticalGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────────────────────────
  // Card Decoration Helpers
  // ─────────────────────────────────────────────────────────────
  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: border, width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x08000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x05000000),
        blurRadius: 6,
        offset: Offset(0, 1),
      ),
    ],
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: border, width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0C000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x06000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // ─────────────────────────────────────────────────────────────
  // Risk Color Helpers
  // ─────────────────────────────────────────────────────────────
  static Color getRiskColor(String level) {
    switch (level.toLowerCase()) {
      case '5':
      case 'level 5':
      case 'critical':
      case 'red':
        return criticalRed;
      case '4':
      case 'level 4':
      case 'warning':
      case 'orange':
        return warningOrange;
      case '3':
      case 'level 3':
      case 'alert':
      case 'yellow':
        return advisoryYellow;
      case '2':
      case 'level 2':
      case 'advisory':
      case 'blue':
        return rainBlue;
      case '1':
      case 'level 1':
      case 'safe':
      case 'green':
      default:
        return safeGreen;
    }
  }

  static Color getRiskBg(String level) {
    switch (level.toLowerCase()) {
      case '5':
      case 'level 5':
      case 'critical':
      case 'red':
        return criticalRedBg;
      case '4':
      case 'level 4':
      case 'warning':
      case 'orange':
        return warningOrangeBg;
      case '3':
      case 'level 3':
      case 'alert':
      case 'yellow':
        return advisoryYellowBg;
      case '2':
      case 'level 2':
      case 'advisory':
      case 'blue':
        return level2BlueBg;
      case '1':
      case 'level 1':
      case 'safe':
      case 'green':
      default:
        return safeGreenBg;
    }
  }

  static Color getRiskBorder(String level) {
    switch (level.toLowerCase()) {
      case '5':
      case 'level 5':
      case 'critical':
      case 'red':
        return criticalRedBorder;
      case '4':
      case 'level 4':
      case 'warning':
      case 'orange':
        return warningOrangeBorder;
      case '3':
      case 'level 3':
      case 'alert':
      case 'yellow':
        return advisoryYellowBorder;
      case '2':
      case 'level 2':
      case 'advisory':
      case 'blue':
        return const Color(0xFFBAE6FD);
      case '1':
      case 'level 1':
      case 'safe':
      case 'green':
      default:
        return safeGreenBorder;
    }
  }
}
