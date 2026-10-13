
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/delivery.dart';

class DeliveryService {
  DeliveryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _deliveriesCollection =>
      _firestore.collection('deliveries');

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
    final furnitureId =
        _validateId(delivery.furnitureId, 'Furniture ID');
    final customerId =
        _validateId(delivery.customerId, 'Customer ID');

    final document = _deliveriesCollection.doc();

    await document.set({
      ...delivery.toMap(),
      'bookingId': bookingId,
      'furnitureId': furnitureId,
      'customerId': customerId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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

  Future<List<Delivery>> getDeliveriesForBooking(
    String bookingId,
  ) async {
    final id = _validateId(bookingId, 'Booking ID');

    final snapshot = await _deliveriesCollection
        .where('bookingId', isEqualTo: id)
        .get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchDeliveriesForBooking(
    String bookingId,
  ) {
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

  Future<List<Delivery>> getDeliveriesForFurniture(
    String furnitureId,
  ) async {
    final id = _validateId(furnitureId, 'Furniture ID');

    final snapshot = await _deliveriesCollection
        .where('furnitureId', isEqualTo: id)
        .get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchDeliveriesForFurniture(
    String furnitureId,
  ) {
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

  Future<List<Delivery>> getDeliveriesForCustomer(
    String customerId,
  ) async {
    final id = _validateId(customerId, 'Customer ID');

    final snapshot = await _deliveriesCollection
        .where('customerId', isEqualTo: id)
        .get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchDeliveriesForCustomer(
    String customerId,
  ) {
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

  Future<List<Delivery>> getDeliveriesByType(
    DeliveryType type,
  ) async {
    final snapshot = await _deliveriesCollection
        .where('type', isEqualTo: type.name)
        .get();

    return snapshot.docs
        .map((doc) => Delivery.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Delivery>> watchDeliveriesByType(
    DeliveryType type,
  ) {
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

  // ---------------------------------------------------------------------------
  // Assign staff
  // ---------------------------------------------------------------------------

  Future<void> assignStaff(
    String deliveryId,
    String staffId,
  ) async {
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

  Future<void> updateDeliveryNotes(
    String deliveryId,
    String? notes,
  ) async {
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
