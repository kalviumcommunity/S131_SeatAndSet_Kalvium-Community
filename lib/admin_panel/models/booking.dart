
import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  reserved,
  scheduled,
  outForDelivery,
  delivered,
  active,
  pickupScheduled,
  pickedUp,
  returned,
  cancelled,
}

class Booking {
  final String id;
  final String customerId;
  final String furnitureId;
  final DateTime startDate;
  final DateTime endDate;
  final BookingStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.customerId,
    required this.furnitureId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Validate the booking before saving it.
  void validate() {
    if (customerId.trim().isEmpty) {
      throw ArgumentError('Customer ID cannot be empty.');
    }

    if (furnitureId.trim().isEmpty) {
      throw ArgumentError('Furniture ID cannot be empty.');
    }

    if (!endDate.isAfter(startDate)) {
      throw ArgumentError('End date must be after start date.');
    }
  }

  /// Convert the booking into Firestore-compatible data.
  Map<String, dynamic> toMap() {
    validate();

    return {
      'customerId': customerId.trim(),
      'furnitureId': furnitureId.trim(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status.name,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Build a booking from a Firestore document.
  factory Booking.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return Booking(
      id: documentId,
      customerId: _requiredString(map, 'customerId'),
      furnitureId: _requiredString(map, 'furnitureId'),
      startDate: _readDate(map['startDate'], 'startDate'),
      endDate: _readDate(map['endDate'], 'endDate'),
      status: BookingStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => BookingStatus.reserved,
      ),
      createdAt: _optionalDate(map['createdAt']),
      updatedAt: _optionalDate(map['updatedAt']),
    );
  }

  factory Booking.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw FormatException(
        'Booking document ${document.id} has no data.',
      );
    }

    return Booking.fromMap(document.id, data);
  }

  static String _requiredString(
    Map<String, dynamic> map,
    String field,
  ) {
    final value = map[field];

    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
        'Booking field "$field" is missing or invalid.',
      );
    }

    return value.trim();
  }

  static DateTime _readDate(dynamic value, String field) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    throw FormatException(
      'Booking field "$field" is missing or invalid.',
    );
  }

  static DateTime? _optionalDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
