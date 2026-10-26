import 'package:flutter/material.dart';

import '../data/favorites_controller.dart';
import '../models/furniture.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A furniture image/name/price card with a working favorite toggle —
/// used by the Furniture List and Search screens. Visually the same card
/// shape as Home's "Popular This Month" cards, but generalized to any
/// [Furniture] and reading/writing [FavoritesController] directly instead
/// of a per-screen local `Set`, so a favorite toggled here is instantly
/// reflected everywhere else it's shown.
class FurnitureCard extends StatelessWidget {
  const FurnitureCard({super.key, required this.item, required this.onTap});

  final Furniture item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.card),
                  ),
                  child: AspectRatio(
                    aspectRatio: 205 / 164,
                    child: Image.asset(item.imageAsset, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder<Set<String>>(
                    valueListenable: FavoritesController.instance.favoriteIds,
                    builder: (context, favoriteIds, _) {
                      final bool isFavorited = favoriteIds.contains(item.id);
                      return Material(
                        color: AppColors.surface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () =>
                              FavoritesController.instance.toggle(item.id),
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: isFavorited
                                  ? AppColors.danger
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.price,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
