import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:seat_and_set/admin_panel/models/booking.dart';
import 'package:seat_and_set/admin_panel/services/booking_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late BookingService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = BookingService(firestore: firestore);
  });

  Booking makeBooking({
    String customerId = 'customer1',
    String furnitureId = 'sofa1',
    DateTime? startDate,
    DateTime? endDate,
    BookingStatus status = BookingStatus.reserved,
  }) {
    return Booking(
      id: '',
      customerId: customerId,
      furnitureId: furnitureId,
      startDate: startDate ?? DateTime(2026, 11, 1),
      endDate: endDate ?? DateTime(2026, 11, 5),
      status: status,
    );
  }

  group('BookingService tests', () {
    test('creates a valid booking', () async {
      final id = await service.createBooking(makeBooking());

      expect(id, isNotEmpty);

      final saved = await service.getBookingById(id);

      expect(saved, isNotNull);
      expect(saved!.furnitureId, 'sofa1');
      expect(saved.customerId, 'customer1');
    });

    test('rejects overlapping bookings for the same furniture', () async {
      await service.createBooking(makeBooking());

      expect(
        () => service.createBooking(
          makeBooking(
            startDate: DateTime(2026, 11, 3),
            endDate: DateTime(2026, 11, 7),
          ),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('allows bookings for different furniture items', () async {
      await service.createBooking(makeBooking());

      final id = await service.createBooking(
        makeBooking(furnitureId: 'chair1'),
      );

      expect(id, isNotEmpty);
    });

    test('allows consecutive bookings without overlap', () async {
      await service.createBooking(makeBooking());

      final id = await service.createBooking(
        makeBooking(
          startDate: DateTime(2026, 11, 5),
          endDate: DateTime(2026, 11, 9),
        ),
      );

      expect(id, isNotEmpty);
    });

    test('does not report a conflict for cancelled bookings', () async {
      await service.createBooking(makeBooking(status: BookingStatus.cancelled));

      final conflict = await service.hasBookingConflict(makeBooking());

      expect(conflict, isFalse);
    });

    test('updates booking status', () async {
      final id = await service.createBooking(makeBooking());

      await service.updateBookingStatus(id, BookingStatus.cancelled);

      final updated = await service.getBookingById(id);

      expect(updated!.status, BookingStatus.cancelled);
    });

    test('deletes a booking', () async {
      final id = await service.createBooking(makeBooking());

      await service.deleteBooking(id);

      final deleted = await service.getBookingById(id);

      expect(deleted, isNull);
    });

    test('removes the reservation lock when deleting a booking', () async {
      final id = await service.createBooking(makeBooking());

      await service.deleteBooking(id);

      final lock = await firestore
          .collection('furniture_booking_locks')
          .doc('sofa1')
          .get();
      expect(lock.data()?['reservations'], isEmpty);
    });

    test('updates dates without conflicting with itself', () async {
      final id = await service.createBooking(makeBooking());

      await service.updateBooking(
        makeBooking(
          startDate: DateTime(2026, 11, 2),
          endDate: DateTime(2026, 11, 6),
        ).copyWithId(id),
      );

      final updated = await service.getBookingById(id);
      expect(updated!.startDate, DateTime(2026, 11, 2));
    });

    test('excludes returned bookings from conflicts', () async {
      await service.createBooking(makeBooking(status: BookingStatus.returned));

      expect(await service.hasBookingConflict(makeBooking()), isFalse);
    });

    test('detects overdue bookings and excludes completed states', () async {
      final overdueId = await service.createBooking(
        makeBooking(
          startDate: DateTime(2026, 9, 27),
          endDate: DateTime(2026, 10, 1),
        ),
      );
      await service.createBooking(
        makeBooking(
          furnitureId: 'chair1',
          startDate: DateTime(2026, 9, 27),
          endDate: DateTime(2026, 10, 1),
          status: BookingStatus.returned,
        ),
      );
      await service.createBooking(
        makeBooking(
          furnitureId: 'table1',
          startDate: DateTime(2026, 9, 27),
          endDate: DateTime(2026, 10, 1),
          status: BookingStatus.cancelled,
        ),
      );

      final overdue = await service.getOverdueBookings(
        now: DateTime(2026, 10, 2),
      );
      expect(overdue.map((booking) => booking.id), contains(overdueId));
      expect(overdue, hasLength(1));
    });

    test('rejects invalid date ranges', () async {
      final booking = makeBooking(
        startDate: DateTime(2026, 11, 10),
        endDate: DateTime(2026, 11, 5),
      );

      expect(() => service.createBooking(booking), throwsArgumentError);
    });
  });
}

extension on Booking {
  Booking copyWithId(String id) {
    return Booking(
      id: id,
      customerId: customerId,
      furnitureId: furnitureId,
      startDate: startDate,
      endDate: endDate,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
