import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/buttons/circle_icon_button.dart';
import '../../widgets/common/app_logo_mark.dart';
import '../../widgets/common/dots_indicator.dart';
import '../sign_in_screen.dart';
import 'onboarding_page_one.dart';
import 'onboarding_page_two.dart';

/// First screen the app shows (see `lib/main.dart`).
///
/// This hosts the 2-page onboarding carousel from
/// `design_reference/01_onboarding_1.png` and `02_onboarding_2.png`. The
/// Skip button, page dots, and Next arrow stay in fixed positions on screen
/// while [PageView] swaps out only the illustration/text content between
/// them — matching how the two reference images share the same chrome.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// Total number of onboarding pages.
  static const int _pageCount = 2;

  final PageController _pageController = PageController();

  /// Index of the page currently visible, kept in sync via [onPageChanged].
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Skips straight past onboarding, to the Sign In screen.
  void _goToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  /// Handles the circular arrow button: advance to the next page, or — on
  /// the final page — leave onboarding entirely.
  void _onNextPressed() {
    final bool isLastPage = _currentPage == _pageCount - 1;
    if (isLastPage) {
      _goToNextScreen();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double sw = screen.width;
    final double sh = screen.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Shared top row: a small logo appears here only on page 2
            // (page 1 shows its own large centered logo as part of the
            // scrollable content below), and "Skip" is always visible.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage == 1
                      ? SizedBox(
                          width: sw * 0.0552,
                          height: sh * 0.0205,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: AppLogoMark(size: sw * 0.0552),
                          ),
                        )
                      : const SizedBox(width: 32, height: 32),
                  _SkipButton(onPressed: _goToNextScreen),
                ],
              ),
            ),

            // The swipeable onboarding content.
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: const [OnboardingPageOne(), OnboardingPageTwo()],
              ),
            ),

            // Shared bottom row: page-progress dots on the left, "Next"
            // arrow button on the right.
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                sh * 0.024,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DotsIndicator(count: _pageCount, currentIndex: _currentPage),
                  CircleIconButton(
                    icon: Icons.arrow_forward,
                    onPressed: _onNextPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The white pill-shaped "Skip" button in the top-right corner.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text('Skip', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
