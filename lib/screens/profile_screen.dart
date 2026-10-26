import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/user_session.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/screen_header.dart';
import 'edit_profile_screen.dart';
import 'favorites_screen.dart';
import 'info_screen.dart';
import 'location_select_screen.dart';
import 'orders_screen.dart';
import 'sign_in_screen.dart';

/// Profile — the "Profile" bottom nav tab.
///
/// Shows the demo [UserSession]'s current name/email/phone (never a
/// hardcoded name — see the class doc on `UserSession`) and a menu of
/// the other account-related screens. No dedicated reference design
/// exists yet for this one, so it's built from the existing theme
/// (cream background, rounded surface cards, the same green/caption
/// text styles used throughout) rather than a bespoke look.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    UserSession.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
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
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(title: 'Profile'),
              const SizedBox(height: 20),

              // Avatar + name/email/phone, reactive to UserSession so
              // Edit Profile's changes show up the instant this screen
              // is back on top.
              ValueListenableBuilder<UserProfile?>(
                valueListenable: UserSession.instance.profile,
                builder: (context, profile, _) {
                  final String name = profile?.name ?? 'Guest User';
                  final String email = profile?.email ?? '';
                  final String phone = profile?.phone ?? '';
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.successBackground,
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(name, style: AppTextStyles.subheading),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              _ProfileMenuCard(
                items: [
                  _ProfileMenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'My Rentals / Orders',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OrdersScreen(),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.favorite_border,
                    label: 'Favorites',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Saved Locations',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        // Profile has no direct link to Home's delivery
                        // location state, so this opens the picker for
                        // browsing — selecting one here doesn't update
                        // Home (that's set from Home's own "Deliver to"
                        // row).
                        builder: (context) => LocationSelectScreen(
                          currentLocation: DemoData.locations.first,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _ProfileMenuCard(
                items: [
                  _ProfileMenuItem(
                    icon: Icons.notifications_none,
                    label: 'Notifications',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InfoScreen(
                          title: 'Notifications',
                          body: 'You\'re all caught up — new order and delivery updates will show up here.',
                        ),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InfoScreen(
                          title: 'Help & Support',
                          body:
                              'Need a hand? Reach us at support@seatandset.com and we\'ll get back to you '
                              'as soon as we can.',
                        ),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InfoScreen(
                          title: 'Privacy Policy',
                          body:
                              'This is a demo build of Seat & Set — no real personal data is collected, '
                              'stored, or shared. A full privacy policy will live here once the app '
                              'connects to a real backend.',
                        ),
                      ),
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    label: 'Terms & Conditions',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const InfoScreen(
                          title: 'Terms & Conditions',
                          body:
                              'This is a demo build of Seat & Set for evaluation purposes only — no '
                              'real rentals, payments, or agreements are made through it.',
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  onPressed: () => _logout(context),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(current: AppTab.profile),
    );
  }
}

/// A rounded card grouping a handful of [_ProfileMenuItem] rows, with
/// hairline dividers between them.
class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({required this.items});

  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1)
              const Divider(height: 1, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.primaryDark),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
