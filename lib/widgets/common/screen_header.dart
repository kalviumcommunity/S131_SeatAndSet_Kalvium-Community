import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// A simple "back button + title" row used at the top of the screens that
/// don't have a reference design yet (Search, Furniture List, Product
/// Details, Location picker, Orders, Profile) — styled to match the
/// circular back button already used on [SignUpScreen] rather than
/// inventing a new look.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.onBack});

  final String title;

  /// Defaults to `Navigator.pop`.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.subheading,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
