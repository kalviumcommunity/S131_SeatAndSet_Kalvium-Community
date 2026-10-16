import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';

class BookingService {
  BookingService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _locksCollection =>
      _firestore.collection('furniture_booking_locks');

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _blocksAvailability(BookingStatus status) {
    return status != BookingStatus.cancelled &&
        status != BookingStatus.returned;
  }

  DateTime _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    throw FormatException('Invalid booking date in Firestore.');
  }

  Map<String, dynamic> _reservationData(Booking booking) {
    return {
      'startDate': Timestamp.fromDate(booking.startDate),
      'endDate': Timestamp.fromDate(booking.endDate),
      'status': booking.status.name,
    };
  }

  bool _reservationConflicts(
    DateTime proposedStart,
    DateTime proposedEnd,
    Map<String, dynamic> existing,
  ) {
    final status = existing['status'] as String?;

    if (status == BookingStatus.cancelled.name ||
        status == BookingStatus.returned.name) {
      return false;
    }

    final existingStart = _readDate(existing['startDate']);
    final existingEnd = _readDate(existing['endDate']);

    // Half-open intervals: [startDate, endDate).
    return proposedStart.isBefore(existingEnd) &&
        existingStart.isBefore(proposedEnd);
  }

  // ---------------------------------------------------------------------------
  // Fetch bookings
  // ---------------------------------------------------------------------------

  Future<List<Booking>> getAllBookings() async {
    final snapshot = await _bookingsCollection.get();

    return snapshot.docs
        .map((doc) => Booking.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Booking>> watchAllBookings() {
    return _bookingsCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  bool _isOverdue(Booking booking, DateTime now) {
    if (booking.status == BookingStatus.cancelled ||
        booking.status == BookingStatus.pickedUp ||
        booking.status == BookingStatus.returned) {
      return false;
    }

    return booking.endDate.isBefore(now);
  }

  /// Returns rentals whose expected end date has passed and are not complete.
  ///
  /// The filter is intentionally performed client-side because the existing
  /// schema has no normalized completion date field.
  Future<List<Booking>> getOverdueBookings({DateTime? now}) async {
    final bookings = await getAllBookings();
    final referenceTime = now ?? DateTime.now();

    return bookings
        .where((booking) => _isOverdue(booking, referenceTime))
        .toList();
  }

  Stream<List<Booking>> watchOverdueBookings({DateTime? now}) {
    return _bookingsCollection.snapshots().map((snapshot) {
      final referenceTime = now ?? DateTime.now();
      return snapshot.docs
          .map((doc) => Booking.fromMap(doc.id, doc.data()))
          .where((booking) => _isOverdue(booking, referenceTime))
          .toList();
    });
  }

  Future<List<Booking>> getBookingsForFurniture(String furnitureId) async {
    final id = furnitureId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Furniture ID cannot be empty.');
    }

    final snapshot = await _bookingsCollection
        .where('furnitureId', isEqualTo: id)
        .get();

    return snapshot.docs
        .map((doc) => Booking.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Booking>> watchBookingsForFurniture(String furnitureId) {
    final id = furnitureId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Furniture ID cannot be empty.');
    }

    return _bookingsCollection
        .where('furnitureId', isEqualTo: id)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<Booking>> getBookingsForCustomer(String customerId) async {
    final id = customerId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Customer ID cannot be empty.');
    }

    final snapshot = await _bookingsCollection
        .where('customerId', isEqualTo: id)
        .get();

    return snapshot.docs
        .map((doc) => Booking.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Booking>> watchBookingsForCustomer(String customerId) {
    final id = customerId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Customer ID cannot be empty.');
    }

    return _bookingsCollection
        .where('customerId', isEqualTo: id)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Booking.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Booking?> getBookingById(String bookingId) async {
    final id = bookingId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }

    final snapshot = await _bookingsCollection.doc(id).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return Booking.fromMap(snapshot.id, snapshot.data()!);
  }

  // ---------------------------------------------------------------------------
  // Conflict detection
  // ---------------------------------------------------------------------------

  /// Checks existing booking records and the reservation lock.
  ///
  /// New bookings created through this service are tracked in the lock document.
  /// Existing bookings created before this mechanism was added must be migrated
  /// into their corresponding lock documents.
  Future<bool> hasBookingConflict(Booking proposedBooking) async {
    proposedBooking.validate();

    final furnitureId = proposedBooking.furnitureId.trim();
    final lockRef = _locksCollection.doc(furnitureId);

    final lockSnapshot = await lockRef.get();
    final reservations =
        lockSnapshot.data()?['reservations'] as Map<String, dynamic>? ?? {};

    for (final entry in reservations.entries) {
      if (entry.key == proposedBooking.id) continue;

      final reservation = Map<String, dynamic>.from(entry.value as Map);

      if (_reservationConflicts(
        proposedBooking.startDate,
        proposedBooking.endDate,
        reservation,
      )) {
        return true;
      }
    }

    // Also check existing booking documents for compatibility with older data.
    final existingBookings = await getBookingsForFurniture(furnitureId);

    return existingBookings.any((existing) {
      if (existing.id == proposedBooking.id) return false;
      if (!_blocksAvailability(existing.status)) return false;

      return proposedBooking.startDate.isBefore(existing.endDate) &&
          existing.startDate.isBefore(proposedBooking.endDate);
    });
  }

  // ---------------------------------------------------------------------------
  // Create booking
  // ---------------------------------------------------------------------------

  /// Creates a booking using a per-furniture transaction lock.
  ///
  /// All new bookings for the same furniture item must use this method for
  /// concurrent conflict prevention.
  Future<String> createBooking(Booking booking) async {
    booking.validate();

    final furnitureId = booking.furnitureId.trim();
    final customerId = booking.customerId.trim();

    if (furnitureId.isEmpty || customerId.isEmpty) {
      throw ArgumentError('Furniture ID and customer ID are required.');
    }

    // Generate the ID before the transaction so retries use the same ID.
    final bookingRef = _bookingsCollection.doc();
    final lockRef = _locksCollection.doc(furnitureId);

    await _firestore.runTransaction<void>((transaction) async {
      final lockSnapshot = await transaction.get(lockRef);

      final reservations = <String, dynamic>{
        ...?lockSnapshot.data()?['reservations'] as Map<String, dynamic>?,
      };

      for (final entry in reservations.entries) {
        final reservation = Map<String, dynamic>.from(entry.value as Map);

        if (_reservationConflicts(
          booking.startDate,
          booking.endDate,
          reservation,
        )) {
          throw StateError(
            'This furniture item is already booked for the selected dates.',
          );
        }
      }

      reservations[bookingRef.id] = _reservationData(booking);

      transaction.set(bookingRef, {
        ...booking.toMap(),
        'customerId': customerId,
        'furnitureId': furnitureId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(lockRef, {
        'furnitureId': furnitureId,
        'reservations': reservations,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return bookingRef.id;
  }

  // ---------------------------------------------------------------------------
  // Update booking
  // ---------------------------------------------------------------------------

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    final id = bookingId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }

    final bookingRef = _bookingsCollection.doc(id);

    await _firestore.runTransaction<void>((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
        throw StateError('Booking not found: $id');
      }

      final data = bookingSnapshot.data()!;
      final furnitureId = data['furnitureId'] as String?;

      if (furnitureId == null || furnitureId.trim().isEmpty) {
        throw StateError('Booking has no valid furniture ID.');
      }

      final lockRef = _locksCollection.doc(furnitureId);
      final lockSnapshot = await transaction.get(lockRef);

      final reservations = <String, dynamic>{
        ...?lockSnapshot.data()?['reservations'] as Map<String, dynamic>?,
      };

      final reservation = <String, dynamic>{
        'startDate': data['startDate'],
        'endDate': data['endDate'],
        'status': status.name,
      };

      reservations[id] = reservation;

      transaction.update(bookingRef, {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(lockRef, {
        'furnitureId': furnitureId,
        'reservations': reservations,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Updates a booking's dates and customer/furniture details.
  ///
  /// This operation validates dates and checks the lock before updating.
  /// Use updateBookingStatus when only the status changes.
  Future<void> updateBooking(Booking booking) async {
    booking.validate();

    final id = booking.id.trim();
    final furnitureId = booking.furnitureId.trim();
    final customerId = booking.customerId.trim();

    if (id.isEmpty || furnitureId.isEmpty || customerId.isEmpty) {
      throw ArgumentError(
        'Booking ID, furniture ID and customer ID are required.',
      );
    }

    final bookingRef = _bookingsCollection.doc(id);
    await _firestore.runTransaction<void>((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
        throw StateError('Booking not found: $id');
      }

      final existingData = bookingSnapshot.data()!;
      final existingFurnitureId = existingData['furnitureId'] as String?;
      if (existingFurnitureId == null || existingFurnitureId.trim().isEmpty) {
        throw StateError('Booking has no valid furniture ID.');
      }

      final oldLockRef = _locksCollection.doc(existingFurnitureId.trim());
      final newLockRef = _locksCollection.doc(furnitureId);
      final oldLockSnapshot = await transaction.get(oldLockRef);
      final newLockSnapshot = oldLockRef.path == newLockRef.path
          ? oldLockSnapshot
          : await transaction.get(newLockRef);

      final reservations = <String, dynamic>{
        ...?newLockSnapshot.data()?['reservations'] as Map<String, dynamic>?,
      };

      if (_blocksAvailability(booking.status)) {
        for (final entry in reservations.entries) {
          if (entry.key == id) continue;

          final reservation = Map<String, dynamic>.from(entry.value as Map);

          if (_reservationConflicts(
            booking.startDate,
            booking.endDate,
            reservation,
          )) {
            throw StateError(
              'This furniture item is already booked for the selected dates.',
            );
          }
        }

        reservations[id] = _reservationData(booking);
      } else {
        reservations.remove(id);
      }

      transaction.set(bookingRef, {
        ...booking.toMap(),
        'customerId': customerId,
        'furnitureId': furnitureId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(newLockRef, {
        'furnitureId': furnitureId,
        'reservations': reservations,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (oldLockRef.path != newLockRef.path) {
        final oldReservations = <String, dynamic>{
          ...?oldLockSnapshot.data()?['reservations'] as Map<String, dynamic>?,
        };
        oldReservations.remove(id);
        transaction.set(oldLockRef, {
          'furnitureId': existingFurnitureId.trim(),
          'reservations': oldReservations,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Delete booking
  // ---------------------------------------------------------------------------

  Future<void> deleteBooking(String bookingId) async {
    final id = bookingId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }

    final bookingRef = _bookingsCollection.doc(id);

    await _firestore.runTransaction<void>((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);

      if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
        throw StateError('Booking not found: $id');
      }

      final data = bookingSnapshot.data()!;
      final furnitureId = data['furnitureId'] as String?;

      if (furnitureId != null && furnitureId.trim().isNotEmpty) {
        final lockRef = _locksCollection.doc(furnitureId);
        final lockSnapshot = await transaction.get(lockRef);

        final reservations = <String, dynamic>{
          ...?lockSnapshot.data()?['reservations'] as Map<String, dynamic>?,
        };

        reservations.remove(id);

        transaction.set(lockRef, {
          'furnitureId': furnitureId,
          'reservations': reservations,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.delete(bookingRef);
    });
  }

  // ---------------------------------------------------------------------------
  // Availability helper
  // ---------------------------------------------------------------------------

  Future<bool> isFurnitureAvailable({
    required String furnitureId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (furnitureId.trim().isEmpty) {
      throw ArgumentError('Furniture ID cannot be empty.');
    }

    if (!endDate.isAfter(startDate)) {
      throw ArgumentError('End date must be after start date.');
    }

    final proposedBooking = Booking(
      id: '',
      customerId: 'availability-check',
      furnitureId: furnitureId.trim(),
      startDate: startDate,
      endDate: endDate,
      status: BookingStatus.reserved,
    );

    return !(await hasBookingConflict(proposedBooking));
  }
}
