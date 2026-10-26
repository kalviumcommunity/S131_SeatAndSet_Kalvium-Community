import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// A circular button containing a single icon.
///
/// Used for the "Next" arrow on the onboarding screens, and will be reused
/// later for things like the back button / favorite button on the Product
/// Details screen (they're all the same shape: a plain circle with an icon
/// in the middle, just with different colors).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = AppColors.primaryDark,
    this.iconColor = AppColors.textOnDark,
    this.size = 52,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      // Material + InkWell (instead of a plain GestureDetector) gives us
      // the small tap ripple effect you'd expect from a real button.
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: iconColor, size: size * 0.45),
        ),
      ),
    );
  }
}
