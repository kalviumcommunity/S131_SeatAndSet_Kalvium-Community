import 'package:flutter/material.dart';

import 'home_screen.dart';

/// Splash screen shown when the Seat & Set app starts.
///
/// This is a [StatefulWidget] (instead of stateless) purely so it can start
/// a timer in [initState] and then navigate to [HomeScreen] once it fires.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToHomeAfterDelay();
  }

  /// Waits briefly (so the splash is actually visible) then replaces this
  /// screen with [HomeScreen]. `pushReplacement` is used instead of `push`
  /// so the user can't navigate "back" to the splash screen.
  Future<void> _goToHomeAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    // `mounted` check avoids navigating after this widget has already
    // been disposed (e.g. if the app was closed during the delay).
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark background gives the app a clean, premium furniture-rental feel.
      backgroundColor: const Color(0xFF111827),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Temporary logo/icon.
            // We can replace this with the actual Seat & Set logo later.
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.chair_outlined,
                size: 50,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 24),

            // Application name.
            const Text(
              'Seat & Set',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Short description/tagline.
            const Text(
              'Furniture Rental Made Simple',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
