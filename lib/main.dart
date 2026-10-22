import 'package:flutter/material.dart';

import 'screens/onboarding/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SeatAndSetApp());
}

/// Root widget of the Seat & Set application.
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
