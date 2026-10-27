import 'package:flutter/material.dart';

import '../admin_panel/models/booking.dart' as admin_booking;
import '../admin_panel/services/booking_service.dart' as admin_service;
import '../data/bookings_controller.dart';
import '../data/user_session.dart';
import '../models/booking.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_bottom_nav.dart';
import 'product_details_screen.dart';

/// My Rentals — screen 9 (`design_reference/09_my_rentals.png`), the
/// "Orders" bottom nav tab.
///
/// --- Data (for viva) ---
/// Lists whatever [BookingsController] has — every booking created by
/// [BookingScreen]'s "Confirm Booking" button — rather than any hardcoded
/// list, so the Product → Booking → Confirm Booking → My Rentals flow
/// always shows real, just-created bookings. [Booking.status] (derived
/// from today's date vs. the booking's rental period) decides which tab a
/// card shows under and which status pill / action buttons it renders.
///
/// --- Tabs (for viva) ---
/// The reference's "Active" tab shows both an "Ongoing" card and an
/// "Upcoming" card together, so "Active" here means "not completed yet"
/// (ongoing + upcoming combined) while "Upcoming" narrows to just the
/// not-yet-started ones and "Past" is completed rentals — matching what
/// the reference screenshot actually shows rather than three mutually
/// exclusive date-only buckets.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

enum _RentalTab { active, upcoming, past }

class _OrdersScreenState extends State<OrdersScreen> {
  _RentalTab _tab = _RentalTab.active;

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) =>
      '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

  List<Booking> _filter(List<Booking> bookings) {
    switch (_tab) {
      case _RentalTab.active:
        return bookings
            .where((b) => b.status != BookingStatus.completed)
            .toList();
      case _RentalTab.upcoming:
        return bookings
            .where((b) => b.status == BookingStatus.upcoming)
            .toList();
      case _RentalTab.past:
        return bookings
            .where((b) => b.status == BookingStatus.completed)
            .toList();
    }
  }

  void _openDetails(Booking booking) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(item: booking.item),
      ),
    );
  }

  void _placeholder(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _cancelBooking(Booking booking) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel booking?'),
        content:
            Text('This will cancel your booking for ${booking.item.name}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel booking',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await admin_service.BookingService().updateBookingStatus(
          booking.id,
          admin_booking.BookingStatus.cancelled,
        );
      } catch (_) {}
      BookingsController.instance.remove(booking.id);
      if (!mounted) return;
      _placeholder('Booking cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = UserSession.instance.currentUid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
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
              const Text('My Rentals', style: AppTextStyles.heading),
              const SizedBox(height: 16),
              _RentalTabBar(
                selected: _tab,
                onChanged: (tab) => setState(() => _tab = tab),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Booking>>(
                  stream: BookingsController.instance.watchCustomerBookings(
                    customerId: currentUid,
                  ),
                  builder: (context, snapshot) {
                    final allBookings =
                        snapshot.data ?? BookingsController.instance.bookings.value;
                    final List<Booking> bookings = _filter(allBookings);
                    if (bookings.isEmpty) {
                      return _EmptyState(
                          tab: _tab, hasAny: allBookings.isNotEmpty);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      itemCount: bookings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final Booking booking = bookings[index];
                        return _BookingCard(
                          booking: booking,
                          formatDate: _formatDate,
                          onTap: () => _openDetails(booking),
                          onExtend: () => _placeholder('Extend request sent'),
                          onRequestPickup: () =>
                              _placeholder('Pickup requested'),
                          onReschedule: () =>
                              _placeholder('Reschedule request sent'),
                          onCancel: () => _cancelBooking(booking),
                          onBookAgain: () => _openDetails(booking),
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
      bottomNavigationBar: const AppBottomNav(current: AppTab.orders),
    );
  }
}

/// The "Active / Upcoming / Past" segmented control.
class _RentalTabBar extends StatelessWidget {
  const _RentalTabBar({required this.selected, required this.onChanged});

  final _RentalTab selected;
  final ValueChanged<_RentalTab> onChanged;

  static const Map<_RentalTab, String> _labels = {
    _RentalTab.active: 'Active',
    _RentalTab.upcoming: 'Upcoming',
    _RentalTab.past: 'Past',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final tab in _RentalTab.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: tab == selected
                        ? AppColors.primaryDark
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    _labels[tab]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: tab == selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: tab == selected
                          ? AppColors.textOnDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.formatDate,
    required this.onTap,
    required this.onExtend,
    required this.onRequestPickup,
    required this.onReschedule,
    required this.onCancel,
    required this.onBookAgain,
  });

  final Booking booking;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;
  final VoidCallback onExtend;
  final VoidCallback onRequestPickup;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  final VoidCallback onBookAgain;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.input),
                        child: Image.asset(
                          booking.item.imageAsset,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.item.name,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${booking.item.price.split('/').first} / month'
                              '${booking.quantity > 1 ? '  ×${booking.quantity}' : ''}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      _StatusPill(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 14),
                  _DateRow(booking: booking, formatDate: formatDate),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: _ActionRow(
              booking: booking,
              onExtend: onExtend,
              onRequestPickup: onRequestPickup,
              onReschedule: onReschedule,
              onCancel: onCancel,
              onBookAgain: onBookAgain,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color background;
    late final Color foreground;
    switch (status) {
      case BookingStatus.ongoing:
        label = 'Ongoing';
        background = AppColors.successBackground;
        foreground = AppColors.successText;
        break;
      case BookingStatus.upcoming:
        label = 'Upcoming';
        background = AppColors.infoBackground;
        foreground = AppColors.infoText;
        break;
      case BookingStatus.completed:
        label = 'Completed';
        background = AppColors.divider;
        foreground = AppColors.textSecondary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

/// "Delivered on / Pickup on" (ongoing), "Delivery on" (upcoming), or
/// "Rented" (completed) — whichever matches the booking's status.
class _DateRow extends StatelessWidget {
  const _DateRow({required this.booking, required this.formatDate});

  final Booking booking;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.ongoing:
        return Row(
          children: [
            Expanded(
              child: _DateBlock(
                label: 'Delivered on',
                date: formatDate(booking.startDate),
              ),
            ),
            Expanded(
              child: _DateBlock(
                label: 'Pickup on',
                date: formatDate(booking.endDate),
              ),
            ),
          ],
        );
      case BookingStatus.upcoming:
        return _DateBlock(
          label: 'Delivery on',
          date: formatDate(booking.startDate),
        );
      case BookingStatus.completed:
        return _DateBlock(
          label: 'Rented',
          date: '${formatDate(booking.startDate)} - ${formatDate(booking.endDate)}',
        );
    }
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.label, required this.date});

  final String label;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 3),
        Text(
          date,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.booking,
    required this.onExtend,
    required this.onRequestPickup,
    required this.onReschedule,
    required this.onCancel,
    required this.onBookAgain,
  });

  final Booking booking;
  final VoidCallback onExtend;
  final VoidCallback onRequestPickup;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  final VoidCallback onBookAgain;

  @override
  Widget build(BuildContext context) {
    const double height = 44;
    switch (booking.status) {
      case BookingStatus.ongoing:
        return Row(
          children: [
            Expanded(
              child: _OutlinedActionButton(
                label: 'Extend',
                height: height,
                onTap: onExtend,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OutlinedActionButton(
                label: 'Request Pickup',
                height: height,
                color: AppColors.primaryDark,
                bold: true,
                onTap: onRequestPickup,
              ),
            ),
          ],
        );
      case BookingStatus.upcoming:
        return Row(
          children: [
            Expanded(
              child: _OutlinedActionButton(
                label: 'Reschedule',
                height: height,
                onTap: onReschedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OutlinedActionButton(
                label: 'Cancel',
                height: height,
                color: AppColors.danger,
                bold: true,
                onTap: onCancel,
              ),
            ),
          ],
        );
      case BookingStatus.completed:
        return SizedBox(
          width: double.infinity,
          child: _OutlinedActionButton(
            label: 'Book Again',
            height: height,
            color: AppColors.primaryDark,
            bold: true,
            onTap: onBookAgain,
          ),
        );
    }
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({
    required this.label,
    required this.height,
    required this.onTap,
    this.color = AppColors.textPrimary,
    this.bold = false,
  });

  final String label;
  final double height;
  final VoidCallback onTap;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: color == AppColors.textPrimary ? AppColors.divider : color,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tab, required this.hasAny});

  final _RentalTab tab;
  final bool hasAny;

  @override
  Widget build(BuildContext context) {
    final String title;
    final String subtitle;
    if (!hasAny) {
      title = 'No rentals yet';
      subtitle = 'Items you rent will show up here.';
    } else {
      switch (tab) {
        case _RentalTab.active:
          title = 'No active rentals';
          subtitle = 'Rentals you book will appear here while they\'re active.';
          break;
        case _RentalTab.upcoming:
          title = 'No upcoming rentals';
          subtitle = 'Bookings that haven\'t started yet will show up here.';
          break;
        case _RentalTab.past:
          title = 'No past rentals';
          subtitle = 'Completed rentals will show up here.';
          break;
      }
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.subheading.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
