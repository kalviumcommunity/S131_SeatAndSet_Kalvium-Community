import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/favorites_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/screen_header.dart';
import '../widgets/furniture_card.dart';
import 'product_details_screen.dart';

/// Favorites — pushed from Profile's "Favorites" row. Shows whichever
/// catalog items [FavoritesController] currently has marked, so hearting
/// an item anywhere else in the app (Home, Browse/Search, Furniture
/// List, Product Details) shows up here too.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            12,
            AppSpacing.screenPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(title: 'Favorites'),
              const SizedBox(height: 16),
              Expanded(
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoritesController.instance.favoriteIds,
                  builder: (context, favoriteIds, _) {
                    final items = DemoData.furniture
                        .where((item) => favoriteIds.contains(item.id))
                        .toList();
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No favorites yet',
                              style: AppTextStyles.subheading.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap the heart on any item to save it here.',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 13,
                            crossAxisSpacing: 13,
                            childAspectRatio: 0.72,
                          ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return FurnitureCard(
                          item: item,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsScreen(item: item),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
