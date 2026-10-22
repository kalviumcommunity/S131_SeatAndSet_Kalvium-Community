import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Central theme configuration for the Seat & Set customer app.
///
/// `MaterialApp` is given this theme once, and every screen/widget picks up
/// the same colors, text styles, and button/card/input shapes automatically
/// — instead of each screen styling its own widgets from scratch. This is
/// built to match the 9 reference designs in `design_reference/`.
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,

      // Drives default Material widget colors (icons, ripples, etc.).
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        primary: AppColors.primaryDark,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.subheading,
      ),

      // Default look for every Card widget: soft rounded corners with a
      // thin hairline border and (almost) no shadow, matching the flat
      // card style used throughout the reference screens.
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),

      // Default look for every ElevatedButton (used by PrimaryButton):
      // a full-width, fully-rounded "pill" button like "Sign In" /
      // "Add to Cart" / "Confirm Booking".
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.textOnDark,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),

      // Default look for outlined buttons, e.g. the "Google" / "Phone OTP"
      // social buttons and the "Extend" / "Reschedule" rental actions.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
        ),
      ),

      // Default look for TextButtons, e.g. "Forgot Password?", "See all".
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: AppTextStyles.link,
        ),
      ),

      // Default look for every text input field (Sign In / Sign Up forms):
      // a filled white rounded box with a visible green border once focused.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(
            color: AppColors.primaryDark,
            width: 1.5,
          ),
        ),
      ),

      // Default look for checkboxes, e.g. "Remember me" / "I agree to the
      // Terms & Privacy Policy" — a solid dark-green filled box when checked.
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryDark
              : AppColors.surface,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.textOnDark),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      textTheme: const TextTheme(
        headlineSmall: AppTextStyles.heading,
        titleMedium: AppTextStyles.subheading,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
      ),
    );
  }
}
