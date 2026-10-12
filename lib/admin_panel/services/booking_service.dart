
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';

class BookingService {
  BookingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  /// Retrieves all bookings for a particular furniture item.
  Future<List<Booking>> getBookingsForFurniture(
    String furnitureId,
  ) async {
    if (furnitureId.trim().isEmpty) {
      throw ArgumentError('Furniture ID cannot be empty.');
    }

    final snapshot = await _bookingsCollection
        .where('furnitureId', isEqualTo: furnitureId.trim())
        .get();

    return snapshot.docs
        .map((doc) => Booking.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Watches bookings for a particular furniture item in real time.
  Stream<List<Booking>> watchBookingsForFurniture(
    String furnitureId,
  ) {
    if (furnitureId.trim().isEmpty) {
      throw ArgumentError('Furniture ID cannot be empty.');
    }

    return _bookingsCollection
        .where('furnitureId', isEqualTo: furnitureId.trim())
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Checks whether a proposed booking overlaps an existing booking.
  Future<bool> hasBookingConflict(Booking proposedBooking) async {
    proposedBooking.validate();

    final existingBookings = await getBookingsForFurniture(
      proposedBooking.furnitureId,
    );

    return existingBookings.any((existing) {
      if (existing.id == proposedBooking.id) {
        return false;
      }

      // Cancelled and returned bookings no longer block availability.
      if (existing.status == BookingStatus.cancelled ||
          existing.status == BookingStatus.returned) {
        return false;
      }

      // Two date ranges overlap when each starts before the other ends.
      return proposedBooking.startDate.isBefore(existing.endDate) &&
          existing.startDate.isBefore(proposedBooking.endDate);
    });
  }

  /// Creates a booking if no existing booking overlaps its date range.
  Future<String> createBooking(Booking booking) async {
    booking.validate();

    final hasConflict = await hasBookingConflict(booking);

    if (hasConflict) {
      throw StateError(
        'This furniture item is already booked for the selected dates.',
      );
    }

    final document = _bookingsCollection.doc();

    await document.set({
      ...booking.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return document.id;
  }

  /// Updates the status of an existing booking.
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    if (bookingId.trim().isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }

    await _bookingsCollection.doc(bookingId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a booking document.
  Future<void> deleteBooking(String bookingId) async {
    if (bookingId.trim().isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }

    await _bookingsCollection.doc(bookingId).delete();
  }
}
