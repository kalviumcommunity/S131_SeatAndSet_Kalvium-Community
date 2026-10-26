import 'package:flutter/foundation.dart';

import '../models/booking.dart';

/// App-wide (in-memory, demo-only) store of confirmed bookings.
///
/// Same `ValueNotifier` singleton pattern as [FavoritesController] — no
/// backend, so bookings reset on app restart, but every screen that reads
/// [bookings] (My Rentals) reacts immediately when [BookingScreen] adds a
/// new one.
class BookingsController {
  BookingsController._();

  static final BookingsController instance = BookingsController._();

  final ValueNotifier<List<Booking>> bookings = ValueNotifier<List<Booking>>(
    const [],
  );

  void add(Booking booking) {
    bookings.value = [booking, ...bookings.value];
  }

  /// Removes a booking by id — used by My Rentals' "Cancel" action on an
  /// upcoming booking.
  void remove(String id) {
    bookings.value = bookings.value.where((b) => b.id != id).toList();
  }
}
