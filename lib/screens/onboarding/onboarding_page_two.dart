import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

/// Body content of onboarding screen 2 (`design_reference/02_onboarding_2.png`).
///
/// Shows the bedroom illustration card with two floating info badges
/// ("From ₹399/month" and "Free Delivery"), followed by a left-aligned
/// heading and description. The small top-left logo, Skip button, page
/// dots, and Next arrow all live in the parent [OnboardingScreen].
///
/// --- Illustration artwork (for viva) ---
/// Earlier versions redrew the bedroom (wall art, window, bed, plant) from
/// plain Flutter shapes positioned by hand-measured percentages. Getting
/// every shape — especially the plant's leaves — to visually match the
/// reference's actual artwork exactly proved not to converge on repeated
/// visual review. This version follows the same approach already used on
/// [OnboardingPageOne]: the illustration card region was cropped directly
/// out of `design_reference/02_onboarding_2.png` with a small Python/Pillow
/// script and saved as `assets/images/onboarding_2_illustration.png`, then
/// loaded here with [Image.asset]. That guarantees the artwork is
/// pixel-identical to the reference instead of an approximation.
///
/// --- Responsive sizing (for viva) ---
/// Every size/gap/color below was measured directly off
/// `design_reference/02_onboarding_2.png` (518 x 1160): card width/height
/// and both badge offsets are all percentages of either the screen or the
/// card's own box (the same approach used on [OnboardingPageOne]).
class OnboardingPageTwo extends StatelessWidget {
  const OnboardingPageTwo({super.key});

  /// Path to the cropped illustration-card artwork (see class doc above).
  static const String _illustrationAsset =
      'assets/images/onboarding_2_illustration.png';

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double sw = screen.width;
    final double sh = screen.height;

    // Card width and height were measured independently off the reference
    // (card box vs. the full phone frame in the mockup) rather than from a
    // single aspect ratio, so both dimensions match the mockup's own
    // percentages exactly instead of compounding one measurement's error
    // into the other.
    final double cardWidth = sw * 0.798;
    final double cardHeight = sh * 0.430;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gap from the Skip/logo row to the card top — measured as the
          // reference's card-top offset minus that row's own height.
          SizedBox(height: sh * 0.037),

          // The bedroom illustration + its two floating badges are layered
          // with a Stack so the badges can overlap the image edges, exactly
          // like in the reference design.
          SizedBox(
            width: double.infinity,
            child: Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
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

                    // "From ₹399 per month" badge, floating above the
                    // card's top-right corner (clear of the window below
                    // it, unlike the old fixed-offset version).
                    Positioned(
                      top: -cardHeight * 0.040,
                      right: -cardWidth * 0.050,
                      child: _InfoBadge(
                        leading: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3DFC4),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '₹',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: 'From ₹399',
                        subtitle: 'per month',
                        minWidth: cardWidth * 0.440,
                      ),
                    ),

                    // "Free Delivery & setup at home" badge, floating over
                    // the bottom-left, slightly below and left of the
                    // card's bottom-left corner.
                    Positioned(
                      left: -cardWidth * 0.053,
                      bottom: -cardHeight * 0.034,
                      child: _InfoBadge(
                        leading: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.successBackground,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.successText,
                          ),
                        ),
                        title: 'Free Delivery',
                        subtitle: '& setup at home',
                        minWidth: cardWidth * 0.469,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Extra space to account for the badge hanging below the image.
          SizedBox(height: sh * 0.0625),

          Text(
            'Rent. Swap.\nUpgrade Anytime.',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.primaryDark,
              fontSize: sw * 0.063,
            ),
          ),
          SizedBox(height: sh * 0.02),
          const Text(
            'Flexible monthly plans with free delivery, setup '
            'and easy returns whenever you move.',
            style: AppTextStyles.body,
          ),

          SizedBox(height: sh * 0.03),
        ],
      ),
    );
  }
}

/// A small white rounded "floating" card with an icon, a bold title and a
/// gray subtitle — used for both badges on this page.
class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.minWidth,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: minWidth == null
          ? null
          : BoxConstraints(minWidth: minWidth!),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.input),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
