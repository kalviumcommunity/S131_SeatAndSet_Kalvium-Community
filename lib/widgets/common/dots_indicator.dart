import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A row of small dots showing progress through a set of pages
/// (e.g. the 2 onboarding screens, or the image carousel on Product Details).
///
/// The active dot is drawn as a wider "pill" shape in the brand green,
/// while inactive dots are small gray circles — matching the reference
/// designs.
class DotsIndicator extends StatelessWidget {
  const DotsIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  /// Total number of pages/dots to show.
  final int count;

  /// Index of the currently active page (0-based).
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryDark : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
