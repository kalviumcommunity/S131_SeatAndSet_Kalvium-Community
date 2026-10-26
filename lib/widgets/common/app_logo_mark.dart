import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The small "Seat and Set" logo mark: a dark green triangle (roof shape)
/// with a light rectangle "door" cut into its base.
///
/// There is no real brand asset file in this project (per the project
/// scope: frontend only, no external assets pipeline), so this is
/// recreated directly with Flutter shapes (a [ClipPath] triangle + a small
/// rounded rectangle) instead of an image. It appears on both onboarding
/// screens and will be reused on the Sign In / Sign Up screens later.
class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 40});

  /// Width and height of the logo's bounding box.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // The triangular "roof" shape, clipped out of a solid-color box.
          ClipPath(
            clipper: _TriangleClipper(),
            child: Container(color: AppColors.primaryDark),
          ),
          // The small "door" notch near the base of the triangle.
          Container(
            width: size * 0.22,
            height: size * 0.32,
            margin: EdgeInsets.only(bottom: size * 0.06),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clips a rectangle down to a simple upward-pointing triangle.
class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0) // top point
      ..lineTo(size.width, size.height) // bottom-right corner
      ..lineTo(0, size.height) // bottom-left corner
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
