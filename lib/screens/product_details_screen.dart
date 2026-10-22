import 'package:flutter/material.dart';
import '../data/favorites_controller.dart';
import '../models/furniture.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'booking_screen.dart';

/// Product Details (`design_reference/07_product_details.png`).
///
/// Reachable from Home's "Popular This Month" cards, and from the
/// Furniture List / Search results — always driven by the [item] passed
/// in, never a hardcoded product.
///
/// --- Layout (for viva) ---
/// A full-bleed hero image (behind the status bar) with circular
/// back/favorite buttons and a page-dot row floating over it, then a
/// white sheet with rounded top corners pulled up over the image's
/// bottom edge by its own corner radius (`Transform.translate`) for the
/// classic "bottom sheet over hero image" look. Spacing/sizes are fixed
/// dp values measured directly off the reference (it crops to the same
/// ~393 x 852 design canvas as every other screen, so 1 reference px ≈
/// 0.8326 dp).
///
/// The reference's primary button reads "Add to Cart" (kept verbatim
/// for visual fidelity) but — per this app's actual flow, a furniture
/// *rental* app with no cart concept — it navigates to [BookingScreen]
/// (screen 8) rather than adding to a cart.
///
/// The reference doesn't display a separate category badge anywhere on
/// this screen (unlike the old placeholder version of this screen), so
/// none is shown here either — `item.category` still drives which
/// product this is, it's just not its own visible label on this screen.
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.item});

  final Furniture item;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  static const List<Color> _colorOptions = [
    Color(0xFF364E3F),
    Color(0xFF4F5250),
    Color(0xFF3A3A3A),
    Color(0xFFBA534F),
  ];

  int _selectedColor = 0;
  int _quantity = 1;

  void _incrementQuantity() => setState(() => _quantity++);

  void _decrementQuantity() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final Furniture item = widget.item;
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final double topInset = MediaQuery.of(context).padding.top;
    final double heroHeight = sh * 0.489;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full-bleed hero image, status bar included — back/favorite
            // buttons and the page-dot row float over it.
            SizedBox(
              height: heroHeight,
              width: sw,
              child: Stack(
                children: [
                  Positioned.fill(child: Image.asset(item.imageAsset, fit: BoxFit.cover)),
                  Positioned(
                    top: topInset + 8,
                    left: AppSpacing.screenPadding,
                    child: _CircleButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Positioned(
                    top: topInset + 8,
                    right: AppSpacing.screenPadding,
                    child: ValueListenableBuilder<Set<String>>(
                      valueListenable: FavoritesController.instance.favoriteIds,
                      builder: (context, favoriteIds, _) {
                        final bool isFavorited = favoriteIds.contains(item.id);
                        return _CircleButton(
                          icon: isFavorited ? Icons.favorite : Icons.favorite_border,
                          iconColor: isFavorited ? AppColors.danger : AppColors.textPrimary,
                          onTap: () => FavoritesController.instance.toggle(item.id),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: const Center(child: _DotsRow()),
                  ),
                ],
              ),
            ),

            // White sheet, pulled up over the image's bottom edge by its
            // own corner radius so the rounded top corners overlap it.
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  24,
                  AppSpacing.screenPadding,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTextStyles.subheading.copyWith(fontSize: 21),
                          ),
                        ),
                        ValueListenableBuilder<Set<String>>(
                          valueListenable: FavoritesController.instance.favoriteIds,
                          builder: (context, favoriteIds, _) {
                            final bool isFavorited = favoriteIds.contains(item.id);
                            return InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => FavoritesController.instance.toggle(item.id),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorited ? AppColors.danger : AppColors.textPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 19),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          item.price.split('/').first,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '/ month',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Color(0xFFE8B54F)),
                        const SizedBox(width: 5),
                        Text(
                          '${item.rating}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${item.reviewCount} reviews)',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      item.description,
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 35),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select Color', style: AppTextStyles.fieldLabel),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  for (var i = 0; i < _colorOptions.length; i++) ...[
                                    _ColorSwatch(
                                      color: _colorOptions[i],
                                      selected: _selectedColor == i,
                                      onTap: () => setState(() => _selectedColor = i),
                                    ),
                                    if (i != _colorOptions.length - 1) const SizedBox(width: 11),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Quantity', style: AppTextStyles.fieldLabel),
                              const SizedBox(height: 10),
                              _QuantityStepper(
                                quantity: _quantity,
                                onDecrement: _decrementQuantity,
                                onIncrement: _incrementQuantity,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.input)),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(item: item, quantity: _quantity),
                          ),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The circular white back/favorite buttons floating over the hero image.
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: iconColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// The page-dot row over the bottom of the hero image — the demo catalog
/// has one photo per item, so this is a static 3-dot visual (matching
/// the reference) rather than a real `PageView` indicator.
class _DotsRow extends StatelessWidget {
  const _DotsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 6,
          decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        _dot(),
        const SizedBox(width: 6),
        _dot(),
      ],
    );
  }

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(color: Color(0xFFBCBCBC), shape: BoxShape.circle),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.selected, required this.onTap});

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: selected ? Border.all(color: AppColors.primaryDark, width: 1.5) : null,
        ),
        child: DecoratedBox(decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onDecrement, required this.onIncrement});

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          _stepperButton(Icons.remove, onDecrement),
          Expanded(
            child: Center(
              child: Text('$quantity', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          _stepperButton(Icons.add, onIncrement),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(width: 38, height: 38, child: Icon(icon, size: 16, color: AppColors.textPrimary)),
    );
  }
}
