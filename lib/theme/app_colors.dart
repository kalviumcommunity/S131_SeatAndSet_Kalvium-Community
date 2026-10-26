import 'package:flutter/material.dart';

/// All the colors used across the Seat & Set customer app.
///
/// These values were picked by eye from the 9 reference PNGs in
/// `design_reference/` (onboarding, sign in/up, home, furniture list,
/// product details, booking, my rentals). Keeping every color in one place
/// makes the UI consistent and makes it easy to re-theme the whole app
/// later by editing just this file.
class AppColors {
  AppColors._(); // Prevents creating instances of this class.

  // Deep forest green — the app's main brand color. Used for primary
  // buttons, the active bottom-nav pill, headings on onboarding screens,
  // and the "Seat and Set" logo mark.
  static const Color primaryDark = Color(0xFF1E4034);
  static const Color primary = Color(0xFF2A5745);

  // Warm tan/wood accent, used for furniture icon illustrations
  // (e.g. the icons inside SectionCard / category tiles).
  static const Color accent = Color(0xFFC9A878);

  // Soft sage green used for promo banners (Home "Style Your Space" card)
  // and the illustration banner on the Sign In screen.
  static const Color accentSage = Color(0xFFD8E2D3);

  // Screen background (warm cream, not pure white) vs. card/surface color.
  static const Color background = Color(0xFFF3EEE6);
  static const Color surface = Colors.white;

  // Text colors.
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color textOnDark = Colors.white;

  // Borders and dividers (card outlines, input field borders).
  static const Color divider = Color(0xFFE6E1D8);

  // Status colors for rental badges (see "My Rentals" screen) and
  // destructive actions (e.g. the "Cancel" button).
  static const Color successBackground = Color(0xFFDCEFE2);
  static const Color successText = Color(0xFF1E7A4C);
  static const Color infoBackground = Color(0xFFDCE8FB);
  static const Color infoText = Color(0xFF2F6FED);
  static const Color danger = Color(0xFFD9534F);
}
