import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Reusable text styles for the Seat & Set customer app.
///
/// Using named styles instead of repeating fontSize/fontWeight/color on
/// every Text widget keeps typography consistent across screens.
class AppTextStyles {
  AppTextStyles._();

  // Big screen titles, e.g. "Welcome Back", "Create Account", "My Rentals".
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Section titles within a screen, e.g. "Categories", "Rental Period".
  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // Small gray text, e.g. subtitles under a heading or helper copy.
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Label shown above a text field, e.g. "Email or Phone", "Password".
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
  );

  // Tappable text links in brand green, e.g. "Sign up", "Forgot Password?",
  // "See all".
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryDark,
  );

  // Large bold price text, e.g. "₹799" on Product Details.
  static const TextStyle price = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark,
  );
}
