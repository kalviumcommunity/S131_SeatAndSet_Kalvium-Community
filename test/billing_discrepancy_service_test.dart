import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seat_and_set/admin_panel/models/billing_discrepancy.dart';
import 'package:seat_and_set/admin_panel/models/booking.dart';
import 'package:seat_and_set/admin_panel/models/delivery.dart';
import 'package:seat_and_set/admin_panel/services/billing_discrepancy_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late BillingDiscrepancyService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = BillingDiscrepancyService(firestore: firestore);
  });

  test('detects overdue rental discrepancy', () async {
    final now = DateTime(2026, 11, 10);
    await firestore.collection('bookings').doc('b1').set({
      'customerId': 'cust1',
      'furnitureId': 'furn1',
      'startDate': Timestamp.fromDate(DateTime(2026, 11, 1)),
      'endDate': Timestamp.fromDate(DateTime(2026, 11, 5)),
      'status': BookingStatus.active.name,
    });

    final discrepancies = await service.detectDiscrepancies(referenceTime: now);

    expect(discrepancies, hasLength(2)); // overdue + missing delivery record
    final overdue = discrepancies.firstWhere(
      (d) => d.type == DiscrepancyType.overdueRental,
    );
    expect(overdue.bookingId, 'b1');
    expect(overdue.severity, DiscrepancySeverity.medium); // 5 days overdue
  });

  test('detects missing delivery record for active booking', () async {
    final now = DateTime(2026, 11, 3);
    await firestore.collection('bookings').doc('b2').set({
      'customerId': 'cust2',
      'furnitureId': 'furn2',
      'startDate': Timestamp.fromDate(DateTime(2026, 11, 1)),
      'endDate': Timestamp.fromDate(DateTime(2026, 11, 10)),
      'status': BookingStatus.active.name,
    });

    final discrepancies = await service.detectDiscrepancies(referenceTime: now);

    expect(discrepancies, hasLength(1));
    expect(discrepancies.first.type, DiscrepancyType.missingDeliveryRecord);
    expect(discrepancies.first.bookingId, 'b2');
  });

  test('detects delayed pickup discrepancy', () async {
    final now = DateTime(2026, 11, 10);
    await firestore.collection('deliveries').doc('d1').set({
      'bookingId': 'b3',
      'furnitureId': 'furn3',
      'customerId': 'cust3',
      'type': DeliveryType.pickup.name,
      'scheduledAt': Timestamp.fromDate(DateTime(2026, 11, 8)),
      'status': DeliveryStatus.scheduled.name,
    });

    final discrepancies = await service.detectDiscrepancies(referenceTime: now);

    expect(discrepancies, hasLength(1));
    expect(discrepancies.first.type, DiscrepancyType.delayedPickup);
    expect(discrepancies.first.severity, DiscrepancySeverity.high);
  });

  test('returns no discrepancies when all bookings and deliveries are compliant', () async {
    final now = DateTime(2026, 11, 3);
    await firestore.collection('bookings').doc('b4').set({
      'customerId': 'cust4',
      'furnitureId': 'furn4',
      'startDate': Timestamp.fromDate(DateTime(2026, 11, 1)),
      'endDate': Timestamp.fromDate(DateTime(2026, 11, 10)),
      'status': BookingStatus.delivered.name,
    });
    await firestore.collection('deliveries').doc('d4').set({
      'bookingId': 'b4',
      'furnitureId': 'furn4',
      'customerId': 'cust4',
      'type': DeliveryType.delivery.name,
      'scheduledAt': Timestamp.fromDate(DateTime(2026, 11, 1)),
      'status': DeliveryStatus.completed.name,
    });

    final discrepancies = await service.detectDiscrepancies(referenceTime: now);

    expect(discrepancies, isEmpty);
  });
}
