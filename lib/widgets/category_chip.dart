import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// A single selectable filter pill — shared by the Browse/Search and
/// Furniture List screens' category-filter rows, so both look and behave
/// identically instead of two near-duplicate chip widgets.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: selected ? AppColors.primaryDark : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: selected ? AppColors.textOnDark : AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
