import 'package:flutter/material.dart';

import '../../screens/home_screen.dart';
import '../../screens/orders_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/search_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Which bottom-nav tab a screen using [AppBottomNav] represents — drives
/// which icon/label is highlighted and makes tapping that same tab again a
/// no-op instead of pushing a duplicate copy of the current screen.
enum AppTab { home, browse, orders, profile }

/// The floating rounded bottom navigation bar, factored out of
/// [HomeScreen]'s own `_BottomNavBar` so other top-level tabs (starting
/// with [OrdersScreen], screen 9) can show the same bar with themselves
/// highlighted instead of a bare back button.
///
/// [HomeScreen] keeps its own private copy (always "Home" active, so it
/// has nothing to parameterize) rather than being migrated to this widget,
/// to avoid touching an already pixel-matched screen 1-8 file.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.current});

  final AppTab current;

  void _goHome(BuildContext context) {
    if (current == AppTab.home) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _goBrowse(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SearchScreen()));
  }

  void _goOrders(BuildContext context) {
    if (current == AppTab.orders) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const OrdersScreen()));
  }

  void _goProfile(BuildContext context) {
    if (current == AppTab.profile) return;
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

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
                  active: current == AppTab.home,
                  onTap: () => _goHome(context),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.search,
                  label: 'Browse',
                  active: current == AppTab.browse,
                  onTap: () => _goBrowse(context),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.article_outlined,
                  label: 'Orders',
                  active: current == AppTab.orders,
                  onTap: () => _goOrders(context),
                ),
              ),
              Expanded(
                child: _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  active: current == AppTab.profile,
                  onTap: () => _goProfile(context),
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
