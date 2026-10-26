import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/common/app_logo_mark.dart';

/// Body content of onboarding screen 1 (`design_reference/01_onboarding_1.png`).
///
/// Shows the big centered logo + app name, the illustration card, and a
/// two-line caption underneath. The Skip button, page dots, and Next
/// arrow are drawn by the parent [OnboardingScreen] (they stay in the
/// same place across every page).
///
/// --- Illustration artwork (for viva) ---
/// The armchair + plant illustration is NOT drawn with Flutter shapes.
/// It's the actual artwork from the reference mockup: a small Python/
/// Pillow script cropped just the rounded illustration card out of
/// `design_reference/01_onboarding_1.png` and saved it as
/// `assets/images/onboarding_1_illustration.png`, which is declared as an
/// asset in `pubspec.yaml` and loaded below with [Image.asset]. This
/// guarantees the furniture/plant artwork is pixel-identical to the
/// reference, instead of an approximation built from colored boxes.
///
/// --- Responsive sizing (for viva) ---
/// Every size/gap below is computed as a *fraction* of the device's own
/// screen width/height (via [MediaQuery]) instead of a fixed dp number.
/// The fractions came from measuring `01_onboarding_1.png` (524 x 1162)
/// directly: the phone screen's content area inside that mockup image was
/// found, then each element (logo, title, card, ...) was measured as a
/// percentage of that area's width/height. Because everything is a
/// *percentage* of the current screen rather than a copied pixel value,
/// this layout keeps the same proportions as the reference on any device
/// size, not just the exact emulator it was tuned on.
class OnboardingPageOne extends StatelessWidget {
  const OnboardingPageOne({super.key});

  /// Path to the cropped illustration-card artwork (see class doc above).
  static const String _illustrationAsset =
      'assets/images/onboarding_1_illustration.png';

  /// Width/height of the source crop, used to size the card without
  /// stretching/distorting the artwork.
  static const double _illustrationAspect = 398 / 407;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double sw = screen.width;
    final double sh = screen.height;

    // Logo: the reference icon is a noticeably big focal point, roughly
    // 16% of the screen's width, slightly wider than it is tall.
    final double logoWidth = sw * 0.16;
    final double logoHeight = logoWidth * 0.78;
    final double glowDiameter = logoWidth * 1.8;

    // Brand title: bold and large — about 8.8% of screen width per
    // character row, which lands around 36sp on a typical phone.
    final double titleFontSize = sw * 0.088;
    final double taglineFontSize = sw * 0.034;
    final double captionFontSize = sw * 0.05;

    // Illustration card: the reference card is a dominant element, taking
    // up ~84% of the screen's width. Height is derived from the source
    // image's own aspect ratio (rather than a separate screen-height
    // fraction) so the artwork is never stretched out of shape.
    final double cardWidth = sw * 0.84;
    final double cardHeight = cardWidth / _illustrationAspect;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.049),
      child: Column(
        children: [
          SizedBox(height: sh * 0.010),

          // Logo, sitting on a soft warm circular glow — this reproduces
          // the radial "spotlight" look behind the icon in the reference
          // image using a RadialGradient instead of an image.
          SizedBox(
            height: glowDiameter,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: glowDiameter,
                  height: glowDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      // Fading the SAME color down to zero alpha (rather
                      // than to `Colors.transparent`, which is black at
                      // zero alpha) keeps the glow warm all the way to its
                      // edge instead of interpolating through muddy gray.
                      colors: [
                        const Color(0xFFF0E3C9),
                        const Color(0xFFF0E3C9).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                // AppLogoMark itself is always square (it's shared with
                // other screens), so it's stretched slightly here with a
                // FittedBox to match the reference's flatter triangle,
                // without changing the shared widget's shape.
                SizedBox(
                  width: logoWidth,
                  height: logoHeight,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: AppLogoMark(size: logoWidth),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: sh * 0.006),
          Text(
            'Seat and Set',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.primaryDark,
              fontSize: titleFontSize,
            ),
          ),

          SizedBox(height: sh * 0.008),
          Text(
            'Spaces  ·  Made  ·  Simple',
            style: AppTextStyles.caption.copyWith(fontSize: taglineFontSize),
          ),

          // Gap from the tagline down to the illustration card — the
          // largest gap on this screen, matching the generous breathing
          // room above the card in the reference image.
          SizedBox(height: sh * 0.068),

          // The illustration card: real reference artwork (see class doc),
          // clipped to the same rounded-corner radius used elsewhere in
          // the app so its corners match the surrounding UI.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Image.asset(
              _illustrationAsset,
              width: cardWidth,
              height: cardHeight,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),

          SizedBox(height: sh * 0.011),
          Text(
            'Better Furniture\nA Brighter Tomorrow',
            textAlign: TextAlign.center,
            style: AppTextStyles.subheading.copyWith(fontSize: captionFontSize),
          ),

          SizedBox(height: sh * 0.01),
        ],
      ),
    );
  }
}
