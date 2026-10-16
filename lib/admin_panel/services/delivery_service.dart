import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';
import '../models/delivery.dart';
import '../models/inventory_item.dart';

class DeliveryService {
  DeliveryService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _deliveriesCollection =>
      _firestore.collection('deliveries');

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _furnitureCollection =>
      _firestore.collection('furniture');

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  String _validateId(String id, String fieldName) {
    final value = id.trim();

    if (value.isEmpty) {
      throw ArgumentError('$fieldName cannot be empty.');
    }

    return value;
  }

  // ---------------------------------------------------------------------------
  // Create delivery or pickup
  // ---------------------------------------------------------------------------

  Future<String> createDelivery(Delivery delivery) async {
    delivery.validate();

    final bookingId = _validateId(delivery.bookingId, 'Booking ID');
    final furnitureId = _validateId(delivery.furnitureId, 'Furniture ID');
    final customerId = _validateId(delivery.customerId, 'Customer ID');

    final document = _deliveriesCollection.doc();
    final bookingReference = _bookingsCollection.doc(bookingId);
    final furnitureReference = _furnitureCollection.doc(furnitureId);

    await _firestore.runTransaction<void>((transaction) async {
      final bookingSnapshot = await transaction.get(bookingReference);
      final furnitureSnapshot = await transaction.get(furnitureReference);

      if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
        throw StateError('Booking not found: $bookingId');
      }
      if (!furnitureSnapshot.exists || furnitureSnapshot.data() == null) {
        throw StateError('Furniture not found: $furnitureId');
      }

      final booking = Booking.fromMap(
        bookingSnapshot.id,
        bookingSnapshot.data()!,
      );
      if (booking.furnitureId != furnitureId ||
          booking.customerId != customerId) {
        throw StateError(
          'Delivery references do not match the associated booking.',
        );
      }

      transaction.set(document, {
        ...delivery.toMap(),
        'bookingId': bookingId,
        'furnitureId': furnitureId,
        'customerId': customerId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return document.id;
  }

  // ---------------------------------------------------------------------------
  // Fetch deliveries
  // ---------------------------------------------------------------------------

  Future<List<Delivery>> getAllDeliveries() async {
    final snapshot = await _deliveriesCollection.get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchAllDeliveries() {
    return _deliveriesCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Delivery.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<Delivery?> getDeliveryById(String deliveryId) async {
    final id = _validateId(deliveryId, 'Delivery ID');
    final snapshot = await _deliveriesCollection.doc(id).get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }

    return Delivery.fromMap(snapshot.id, snapshot.data()!);
  }

  // ---------------------------------------------------------------------------
  // Fetch deliveries by booking
  // ---------------------------------------------------------------------------

  Future<List<Delivery>> getDeliveriesForBooking(String bookingId) async {
    final id = _validateId(bookingId, 'Booking ID');

    final snapshot = await _deliveriesCollection
        .where('bookingId', isEqualTo: id)
        .get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchDeliveriesForBooking(String bookingId) {
    final id = _validateId(bookingId, 'Booking ID');

    return _deliveriesCollection
        .where('bookingId', isEqualTo: id)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Delivery.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Fetch deliveries by furniture
  // ---------------------------------------------------------------------------

  Future<List<Delivery>> getDeliveriesForFurniture(String furnitureId) async {
    final id = _validateId(furnitureId, 'Furniture ID');

    final snapshot = await _deliveriesCollection
        .where('furnitureId', isEqualTo: id)
        .get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchDeliveriesForFurniture(String furnitureId) {
    final id = _validateId(furnitureId, 'Furniture ID');

    return _deliveriesCollection
        .where('furnitureId', isEqualTo: id)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Delivery.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Fetch deliveries by customer
  // ---------------------------------------------------------------------------

  Future<List<Delivery>> getDeliveriesForCustomer(String customerId) async {
    final id = _validateId(customerId, 'Customer ID');

    final snapshot = await _deliveriesCollection
        .where('customerId', isEqualTo: id)
        .get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchDeliveriesForCustomer(String customerId) {
    final id = _validateId(customerId, 'Customer ID');

    return _deliveriesCollection
        .where('customerId', isEqualTo: id)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Delivery.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Fetch by delivery type
  // ---------------------------------------------------------------------------

  Future<List<Delivery>> getDeliveriesByType(DeliveryType type) async {
    final snapshot = await _deliveriesCollection
        .where('type', isEqualTo: type.name)
        .get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchDeliveriesByType(DeliveryType type) {
    return _deliveriesCollection
        .where('type', isEqualTo: type.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Delivery.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Update delivery status
  // ---------------------------------------------------------------------------

  Future<void> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status,
  ) async {
    final id = _validateId(deliveryId, 'Delivery ID');

    if (status == DeliveryStatus.completed) {
      final delivery = await getDeliveryById(id);
      if (delivery == null) {
        throw StateError('Delivery not found: $id');
      }
      if (delivery.type == DeliveryType.delivery) {
        await completeDelivery(id);
      } else {
        await completePickup(id);
      }
      return;
    }

    await _firestore.runTransaction<void>((transaction) async {
      final reference = _deliveriesCollection.doc(id);
      final snapshot = await transaction.get(reference);

      if (!snapshot.exists) {
        throw StateError('Delivery not found: $id');
      }

      transaction.update(reference, {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Completes a delivery and atomically advances the booking and inventory.
  Future<void> completeDelivery(String deliveryId) async {
    await _completeDelivery(deliveryId, DeliveryType.delivery);
  }

  /// Completes a pickup without marking the rental returned prematurely.
  Future<void> completePickup(String deliveryId) async {
    await _completeDelivery(deliveryId, DeliveryType.pickup);
  }

  Future<void> _completeDelivery(
    String deliveryId,
    DeliveryType expectedType,
  ) async {
    final id = _validateId(deliveryId, 'Delivery ID');
    await _firestore.runTransaction<void>((transaction) async {
      final deliveryReference = _deliveriesCollection.doc(id);
      final deliverySnapshot = await transaction.get(deliveryReference);
      if (!deliverySnapshot.exists || deliverySnapshot.data() == null) {
        throw StateError('Delivery not found: $id');
      }

      final delivery = Delivery.fromMap(id, deliverySnapshot.data()!);
      if (delivery.type != expectedType) {
        throw StateError('Delivery type does not match this operation.');
      }

      final bookingReference = _bookingsCollection.doc(delivery.bookingId);
      final furnitureReference = _furnitureCollection.doc(delivery.furnitureId);
      final bookingSnapshot = await transaction.get(bookingReference);
      final furnitureSnapshot = await transaction.get(furnitureReference);
      if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
        throw StateError('Booking not found: ${delivery.bookingId}');
      }
      if (!furnitureSnapshot.exists || furnitureSnapshot.data() == null) {
        throw StateError('Furniture not found: ${delivery.furnitureId}');
      }

      final booking = Booking.fromMap(
        bookingSnapshot.id,
        bookingSnapshot.data()!,
      );
      if (booking.furnitureId != delivery.furnitureId) {
        throw StateError('Delivery furniture does not match the booking.');
      }

      final bookingStatus = expectedType == DeliveryType.delivery
          ? BookingStatus.delivered
          : BookingStatus.pickedUp;
      final furnitureStatus = expectedType == DeliveryType.delivery
          ? InventoryStatus.rented
          : null;

      if (delivery.status != DeliveryStatus.completed) {
        transaction.update(deliveryReference, {
          'status': DeliveryStatus.completed.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      if (booking.status != bookingStatus) {
        transaction.update(bookingReference, {
          'status': bookingStatus.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      if (furnitureStatus != null) {
        transaction.update(furnitureReference, {
          'status': furnitureStatus.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Marks a completed pickup as returned and releases the furniture.
  Future<void> completeReturn(String deliveryId) async {
    final id = _validateId(deliveryId, 'Delivery ID');
    await _firestore.runTransaction<void>((transaction) async {
      final deliveryReference = _deliveriesCollection.doc(id);
      final deliverySnapshot = await transaction.get(deliveryReference);
      if (!deliverySnapshot.exists || deliverySnapshot.data() == null) {
        throw StateError('Delivery not found: $id');
      }
      final delivery = Delivery.fromMap(id, deliverySnapshot.data()!);
      if (delivery.type != DeliveryType.pickup ||
          delivery.status != DeliveryStatus.completed) {
        throw StateError('A completed pickup is required before return.');
      }

      final bookingReference = _bookingsCollection.doc(delivery.bookingId);
      final furnitureReference = _furnitureCollection.doc(delivery.furnitureId);
      final bookingSnapshot = await transaction.get(bookingReference);
      final furnitureSnapshot = await transaction.get(furnitureReference);
      if (!bookingSnapshot.exists || bookingSnapshot.data() == null) {
        throw StateError('Booking not found: ${delivery.bookingId}');
      }
      if (!furnitureSnapshot.exists || furnitureSnapshot.data() == null) {
        throw StateError('Furniture not found: ${delivery.furnitureId}');
      }

      transaction.update(bookingReference, {
        'status': BookingStatus.returned.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(furnitureReference, {
        'status': InventoryStatus.available.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Assign staff
  // ---------------------------------------------------------------------------

  Future<void> assignStaff(String deliveryId, String staffId) async {
    final id = _validateId(deliveryId, 'Delivery ID');
    final assignedStaffId = _validateId(staffId, 'Staff ID');

    await _deliveriesCollection.doc(id).update({
      'assignedStaffId': assignedStaffId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // Update delivery notes
  // ---------------------------------------------------------------------------

  Future<void> updateDeliveryNotes(String deliveryId, String? notes) async {
    final id = _validateId(deliveryId, 'Delivery ID');

    await _deliveriesCollection.doc(id).update({
      'notes': notes?.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // Update scheduled date and time
  // ---------------------------------------------------------------------------

  Future<void> rescheduleDelivery(
    String deliveryId,
    DateTime scheduledAt,
  ) async {
    final id = _validateId(deliveryId, 'Delivery ID');

    await _deliveriesCollection.doc(id).update({
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // Delete delivery
  // ---------------------------------------------------------------------------

  Future<void> deleteDelivery(String deliveryId) async {
    final id = _validateId(deliveryId, 'Delivery ID');

    await _deliveriesCollection.doc(id).delete();
  }
}
