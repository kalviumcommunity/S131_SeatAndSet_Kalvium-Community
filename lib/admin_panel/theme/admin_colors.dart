import 'package:flutter/material.dart';

class AdminColors {
  // Background Gradients
  static const Color bgDark = Color(0xFF0F1026);
  static const Color bgMid = Color(0xFF1A1B46);
  static const Color bgTop = Color(0xFF141539);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF15163D),
      Color(0xFF1B1C4B),
      Color(0xFF11122C),
    ],
  );

  // Accent & Action
  static const Color primaryButton = Color(0xFF5D53F6);
  static const Color primaryButtonHover = Color(0xFF4F45E6);
  static const Color buttonGlow = Color(0x665D53F6);

  // Input Field
  static const Color fieldBackground = Color(0xFF23254E);
  static const Color fieldBorder = Color(0xFF2F3262);
  static const Color fieldFocusedBorder = Color(0xFF5D53F6);

  // Typography
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0AEC0);
  static const Color textMuted = Color(0xFF718096);
  static const Color textPlaceholder = Color(0xFF636E85);

  // Info Card & Badges
  static const Color badgeBackground = Color(0x2B272A5E);
  static const Color badgeBorder = Color(0x403F448C);
}
