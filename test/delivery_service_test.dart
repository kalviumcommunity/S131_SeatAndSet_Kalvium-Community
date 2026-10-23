import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seat_and_set/admin_panel/models/booking.dart';
import 'package:seat_and_set/admin_panel/models/delivery.dart';
import 'package:seat_and_set/admin_panel/models/inventory_item.dart';
import 'package:seat_and_set/admin_panel/services/delivery_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late DeliveryService service;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    service = DeliveryService(firestore: firestore);
    await firestore.collection('bookings').doc('booking1').set({
      'customerId': 'customer1',
      'furnitureId': 'sofa1',
      'startDate': Timestamp.fromDate(DateTime(2026, 11, 1)),
      'endDate': Timestamp.fromDate(DateTime(2026, 11, 5)),
      'status': BookingStatus.reserved.name,
    });
    await firestore.collection('furniture').doc('sofa1').set({
      'name': 'Sofa',
      'sku': 'SOFA1',
      'type': FurnitureType.sofa.name,
      'status': InventoryStatus.available.name,
    });
  });

  Delivery makeDelivery(DeliveryType type) {
    return Delivery(
      id: '',
      bookingId: 'booking1',
      furnitureId: 'sofa1',
      customerId: 'customer1',
      type: type,
      scheduledAt: DateTime(2026, 10, 30),
      status: DeliveryStatus.scheduled,
    );
  }

  test('creates and fetches a delivery', () async {
    final id = await service.createDelivery(
      makeDelivery(DeliveryType.delivery),
    );

    final delivery = await service.getDeliveryById(id);
    expect(delivery, isNotNull);
    expect(delivery!.type, DeliveryType.delivery);
  });

  test('rejects delivery references that do not exist', () async {
    final invalid = Delivery(
      id: '',
      bookingId: 'missing',
      furnitureId: 'sofa1',
      customerId: 'customer1',
      type: DeliveryType.delivery,
      scheduledAt: DateTime(2026, 10, 30),
      status: DeliveryStatus.scheduled,
    );

    expect(() => service.createDelivery(invalid), throwsA(isA<StateError>()));
  });

  test(
    'completing delivery updates booking and furniture atomically',
    () async {
      final id = await service.createDelivery(
        makeDelivery(DeliveryType.delivery),
      );

      await service.completeDelivery(id);

      final booking = await firestore
          .collection('bookings')
          .doc('booking1')
          .get();
      final furniture = await firestore
          .collection('furniture')
          .doc('sofa1')
          .get();
      final delivery = await service.getDeliveryById(id);
      expect(booking.data()!['status'], BookingStatus.delivered.name);
      expect(furniture.data()!['status'], InventoryStatus.rented.name);
      expect(delivery!.status, DeliveryStatus.completed);
    },
  );

  test('rejects pickup before the booking is delivered', () async {
    expect(
      () => service.createDelivery(makeDelivery(DeliveryType.pickup)),
      throwsA(isA<StateError>()),
    );
  });

  test('rejects delivery for a cancelled booking', () async {
    await firestore.collection('bookings').doc('booking1').update({
      'status': BookingStatus.cancelled.name,
    });

    expect(
      () => service.createDelivery(makeDelivery(DeliveryType.delivery)),
      throwsA(isA<StateError>()),
    );
  });

  test('pickup completion is repeatable and does not mark returned', () async {
    await firestore.collection('bookings').doc('booking1').update({
      'status': BookingStatus.delivered.name,
    });
    final id = await service.createDelivery(makeDelivery(DeliveryType.pickup));

    await service.completePickup(id);
    await service.completePickup(id);

    final booking = await firestore
        .collection('bookings')
        .doc('booking1')
        .get();
    final furniture = await firestore
        .collection('furniture')
        .doc('sofa1')
        .get();
    expect(booking.data()!['status'], BookingStatus.pickedUp.name);
    expect(furniture.data()!['status'], InventoryStatus.available.name);
  });

  test('return completion releases furniture', () async {
    await firestore.collection('bookings').doc('booking1').update({
      'status': BookingStatus.delivered.name,
    });
    final id = await service.createDelivery(makeDelivery(DeliveryType.pickup));
    await service.completePickup(id);
    await service.completeReturn(id);

    final booking = await firestore
        .collection('bookings')
        .doc('booking1')
        .get();
    final furniture = await firestore
        .collection('furniture')
        .doc('sofa1')
        .get();
    expect(booking.data()!['status'], BookingStatus.returned.name);
    expect(furniture.data()!['status'], InventoryStatus.available.name);
  });
}
