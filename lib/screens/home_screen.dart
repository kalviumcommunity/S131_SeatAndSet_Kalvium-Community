import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../models/furniture.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/furniture_card.dart';
import 'furniture_list_screen.dart';
import 'location_select_screen.dart';
import 'orders_screen.dart';
import 'product_details_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

/// Screen 5 — Home (`design_reference/05_home.png`).
///
/// --- Artwork (for viva) ---
/// Every furniture illustration here (the promo banner's sofa, the 4
/// category tiles, the 2 product images) is cropped directly out of
/// `05_home.png` with Pillow — same technique as every other screen's
/// illustrations — instead of redrawn with Flutter shapes, so the artwork
/// is pixel-identical to the reference. The category tiles were cropped
/// *with* their white rounded box baked in (so no extra Container
/// decoration is needed). The product images were originally cropped
/// with the reference's heart/favorite icon baked in too (covered by a
/// real `IconButton` at the same spot), but once that same artwork
/// started getting reused in other layouts (the Furniture List row,
/// `design_reference/06_furniture_list.png`) the baked-in heart showed
/// through as a stray gray patch wherever the crop/aspect ratio
/// differed — so the 2 product photos now use `..._clean.png` variants
/// with the heart patched out in favor of every screen drawing its own
/// real heart icon on top, consistently.
///
/// --- Layout (for viva) ---
/// Spacing is fixed dp values measured directly off the reference (same
/// ~393 x 852 design canvas as every other reference screen, so 1
/// reference px ≈ 0.8326 dp) — not screen-width fractions, matching
/// [SignInScreen]/[SignUpScreen]'s approach for a content screen (as
/// opposed to the onboarding pages' full-bleed illustrations).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Visuals are untouched — same 4 tile images/labels as before — but
  // each tile's label now doubles as the category filter passed to
  // FurnitureListScreen.
  static const List<_Category> _categories = [
    _Category('assets/images/home_category_sofa.png', 'Sofas'),
    _Category('assets/images/home_category_beds.png', 'Beds'),
    _Category('assets/images/home_category_tables.png', 'Tables'),
    _Category('assets/images/home_category_chairs.png', 'Chairs'),
  ];

  // Picked by id (not list position/`.take(2)` — the catalog's own order
  // isn't this section's to depend on) so this always shows exactly the
  // same "Modern Sofa" / "Study Table" items it always has. Sourcing them
  // from DemoData instead of a page-local hardcoded list is what lets
  // ProductDetailsScreen/FurnitureListScreen link back to the same items,
  // with the same favorite state, instead of a visually identical but
  // disconnected duplicate.
  static final List<Furniture> _popular = [
    DemoData.furniture.firstWhere((item) => item.id == 'sofa-modern'),
    DemoData.furniture.firstWhere((item) => item.id == 'table-study'),
  ];

  String _selectedLocation = 'Jammu, J&K';

  Future<void> _pickLocation() async {
    final String? picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) =>
            LocationSelectScreen(currentLocation: _selectedLocation),
      ),
    );
    if (picked != null) {
      setState(() => _selectedLocation = picked);
    }
  }

  void _openSearch() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SearchScreen()));
  }

  void _openFurnitureList({String? category}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FurnitureListScreen(initialCategory: category),
      ),
    );
  }

  void _openProductDetails(Furniture item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ProductDetailsScreen(item: item)),
    );
  }

  void _showPlaceholder(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            12,
            AppSpacing.screenPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Deliver to" location row + notification bell.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primaryDark,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  // Flexible so a longer picked location (e.g. "Jalandhar,
                  // Punjab") ellipsizes instead of overflowing the row —
                  // the default "Jammu, J&K" is short enough that this
                  // never visibly changes its layout.
                  Flexible(
                    child: InkWell(
                      onTap: _pickLocation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deliver to',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  _selectedLocation,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: AppColors.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _showPlaceholder('Notifications'),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.notifications_none,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              TextField(
                readOnly: true,
                onTap: _openSearch,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Search furniture (e.g. sofa, bed...)',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 21),
              // Promo banner — the right ~43% is the reference's own
              // artwork (background gradient + sofa baked in together, so
              // there's no seam against a separately-colored Flutter
              // background); the left side is real text/button on a flat
              // sage `Container` close to that artwork's own left-edge
              // tone.
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Container(
                  color: const Color(0xFFDDE6DD),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Style Your Space',
                                  style: AppTextStyles.subheading.copyWith(
                                    fontSize: 21,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Rent What You Love',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Material(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.pill,
                                    ),
                                    onTap: () => _openFurnitureList(),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Explore',
                                            style: TextStyle(
                                              color: AppColors.textOnDark,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 16,
                                            color: AppColors.textOnDark,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/home_banner_sofa.png',
                          width:
                              (MediaQuery.of(context).size.width -
                                  AppSpacing.screenPadding * 2) *
                              0.434,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _SectionHeader(
                title: 'Categories',
                onSeeAll: () => _openFurnitureList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final category in _categories) ...[
                    Expanded(
                      child: _CategoryTile(
                        category: category,
                        onTap: () =>
                            _openFurnitureList(category: category.label),
                      ),
                    ),
                    if (category != _categories.last) const SizedBox(width: 11),
                  ],
                ],
              ),

              const SizedBox(height: 22),
              _SectionHeader(
                title: 'Popular This Month',
                onSeeAll: () => _openFurnitureList(),
              ),
              const SizedBox(height: 11),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _popular.length; i++) ...[
                    Expanded(
                      child: FurnitureCard(
                        item: _popular[i],
                        onTap: () => _openProductDetails(_popular[i]),
                      ),
                    ),
                    if (i != _popular.length - 1) const SizedBox(width: 13),
                  ],
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _Category {
  const _Category(this.asset, this.label);
  final String asset;
  final String label;
}

/// "Categories" / "Popular This Month" row with a right-aligned "See all"
/// link — shared by both sections.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.subheading.copyWith(fontSize: 19)),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('See all'),
        ),
      ],
    );
  }
}

/// One of the 4 category tiles (image already includes its own white
/// rounded box — see class doc) with its label underneath.
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final _Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: onTap,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(category.asset, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// The floating rounded bottom navigation bar: "Home" is active (pale
/// green pill behind its icon, bold green label) and tapping it is a
/// no-op (already here); the other three each push their own screen —
/// Browse/Orders/Profile aren't pixel-matched to a reference yet (see
/// the note on [ProductDetailsScreen]), but they're real, separate
/// screens, not placeholders.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          8,
        ),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  active: true,
                  onTap: () {},
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.search,
                  label: 'Browse',
                  active: false,
                  // Same Browse/Search screen the Home search bar opens
                  // (see `_openSearch`) — one combined experience, not two.
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.article_outlined,
                  label: 'Orders',
                  active: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  active: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active
        ? AppColors.primaryDark
        : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.successBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
