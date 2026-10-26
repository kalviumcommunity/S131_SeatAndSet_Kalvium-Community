import 'package:flutter/material.dart';

import 'screens/onboarding/onboarding_screen.dart';
import 'theme/app_theme.dart';

/// Entry point for the customer-facing app.
///
/// Kept separate from `lib/main.dart` (the admin app's entry point) so
/// both apps can live in one codebase without either entry point
/// overwriting the other. Run with:
///   flutter run -t lib/main_customer.dart
void main() {
  runApp(const SeatAndSetApp());
}

/// Root widget of the Seat & Set customer application.
class SeatAndSetApp extends StatelessWidget {
  const SeatAndSetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Removes the debug banner from the top-right corner.
      debugShowCheckedModeBanner: false,

      // Application name.
      title: 'Seat & Set',

      // App-wide colors, typography, and widget styles.
      theme: AppTheme.theme,

      // First screen displayed when the app starts.
      home: const OnboardingScreen(),
    );
  }
}
