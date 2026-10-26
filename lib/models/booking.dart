import 'furniture.dart';

/// Where a [Booking] sits relative to today — drives both which "My
/// Rentals" tab it shows up under and which status pill/action buttons
/// its card renders (`design_reference/09_my_rentals.png`).
enum BookingStatus {
  /// Rental period has started and hasn't ended yet.
  ongoing,

  /// Rental period hasn't started yet.
  upcoming,

  /// Rental period has already ended.
  completed,
}

/// A confirmed rental booking — created by [BookingScreen]'s "Confirm
/// Booking" button and stored in [BookingsController] so it can show up
/// later on the My Rentals screen (`design_reference/09_my_rentals.png`).
class Booking {
  const Booking({
    required this.id,
    required this.item,
    required this.quantity,
    required this.startDate,
    required this.endDate,
    required this.addressLabel,
    required this.addressDetail,
    required this.rent,
    required this.deliveryCharge,
    required this.total,
    required this.bookedAt,
  });

  final String id;
  final Furniture item;
  final int quantity;
  final DateTime startDate;
  final DateTime endDate;
  final String addressLabel;
  final String addressDetail;

  /// Pre-computed rupee amounts (item price x quantity x rental months,
  /// plus a flat demo delivery charge) — there's no payment gateway yet,
  /// just the customer-facing summary math.
  final int rent;
  final int deliveryCharge;
  final int total;

  final DateTime bookedAt;

  /// [BookingStatus] derived from today's date vs. [startDate]/[endDate] —
  /// there's no delivery/pickup backend event to drive this off of, so a
  /// booking simply becomes "ongoing" the day its rental period starts and
  /// "completed" the day after it ends.
  BookingStatus get status {
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    if (endDate.isBefore(todayDate)) return BookingStatus.completed;
    if (startDate.isAfter(todayDate)) return BookingStatus.upcoming;
    return BookingStatus.ongoing;
  }
}
