import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A small tappable card with an icon and a label.
///
/// Used on the Home screen for furniture categories (Chairs, Tables, ...),
/// but written generically so it can be reused anywhere a simple
/// icon + label tile is needed.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        // Matches the card's own rounded corners so the tap ripple
        // doesn't spill outside the card shape.
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: AppColors.accent),
              const SizedBox(height: AppSpacing.sm),
              Text(label, style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
