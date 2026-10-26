import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/favorites_controller.dart';
import '../models/furniture.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/category_chip.dart';
import 'product_details_screen.dart';

/// Furniture List (`design_reference/06_furniture_list.png`).
///
/// Reached from Home's category tiles, "See all" links, and the
/// "Explore" banner button.
///
/// --- Layout (for viva) ---
/// Unlike Home/Browse's 2-column grid of square cards, this reference
/// uses a single column of horizontal row cards (image flush left, full
/// row height; name/price/rating stacked to its right; a favorite heart
/// top-right) — different enough from [FurnitureCard] that it gets its
/// own private `_FurnitureRow` widget here rather than reusing it.
/// Spacing/sizes are fixed dp values measured directly off the reference
/// (it crops to the same ~393 x 852 design canvas as every other
/// screen, so 1 reference px ≈ 0.8326 dp).
///
/// --- Category chips (for viva) ---
/// The reference shows sub-type chips ("2 Seater" / "3 Seater" /
/// "L-Shape") specific to browsing within "Sofas" — the demo catalog
/// has no such sub-type data, so this reuses the same top-level category
/// chips ([DemoData.categories]) as the rest of the app instead of
/// inventing fake sub-types; the chip row's look (pill shape, dark-green
/// "All" selected) matches the reference exactly either way.
class FurnitureListScreen extends StatefulWidget {
  const FurnitureListScreen({super.key, this.initialCategory});

  /// Pre-selected category filter chip, or `null` to start on "All".
  final String? initialCategory;

  @override
  State<FurnitureListScreen> createState() => _FurnitureListScreenState();
}

class _FurnitureListScreenState extends State<FurnitureListScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  void _showPlaceholder(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final items = DemoData.byCategory(_selectedCategory);
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
              // Back arrow + centered title + filter icon — all plain
              // (no circular button backgrounds), matching the
              // reference exactly rather than reusing [ScreenHeader]'s
              // circular-back-button look.
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _selectedCategory ?? 'All Furniture',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subheading,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showPlaceholder('Sort & filter'),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.tune, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CategoryChip(
                      label: 'All',
                      selected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    for (final category in DemoData.categories) ...[
                      const SizedBox(width: 8),
                      CategoryChip(
                        label: category,
                        selected: _selectedCategory == category,
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No furniture in this category yet',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _FurnitureRow(
                            item: item,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(item: item),
                              ),
                            ),
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

/// One horizontal furniture row: image flush left (full row height),
/// name/price/rating stacked to its right, favorite heart top-right.
class _FurnitureRow extends StatelessWidget {
  const _FurnitureRow({required this.item, required this.onTap});

  final Furniture item;
  final VoidCallback onTap;

  static const Color _starColor = Color(0xFFE8B54F);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.card),
                    ),
                    child: Image.asset(item.imageAsset, fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 32, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  item.price.split('/').first,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '/ month',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: _starColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.rating} (${item.reviewCount})',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: ValueListenableBuilder<Set<String>>(
                          valueListenable:
                              FavoritesController.instance.favoriteIds,
                          builder: (context, favoriteIds, _) {
                            final bool isFavorited = favoriteIds.contains(
                              item.id,
                            );
                            return InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () =>
                                  FavoritesController.instance.toggle(item.id),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  isFavorited
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 20,
                                  color: isFavorited
                                      ? AppColors.danger
                                      : AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
