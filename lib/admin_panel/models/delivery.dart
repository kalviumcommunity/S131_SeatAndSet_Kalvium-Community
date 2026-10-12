
import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryType {
  delivery,
  pickup,
}

enum DeliveryStatus {
  scheduled,
  inProgress,
  completed,
  delayed,
  cancelled,
}

class Delivery {
  final String id;
  final String bookingId;
  final String furnitureId;
  final String customerId;
  final DeliveryType type;
  final DateTime scheduledAt;
  final DeliveryStatus status;
  final String? assignedStaffId;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Delivery({
    required this.id,
    required this.bookingId,
    required this.furnitureId,
    required this.customerId,
    required this.type,
    required this.scheduledAt,
    required this.status,
    this.assignedStaffId,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Validate required delivery information.
  void validate() {
    if (bookingId.trim().isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }

    if (furnitureId.trim().isEmpty) {
      throw ArgumentError('Furniture ID cannot be empty.');
    }

    if (customerId.trim().isEmpty) {
      throw ArgumentError('Customer ID cannot be empty.');
    }

    if (notes != null && notes!.length > 1000) {
      throw ArgumentError('Notes cannot exceed 1000 characters.');
    }
  }

  /// Convert delivery information into Firestore-compatible data.
  Map<String, dynamic> toMap() {
    validate();

    return {
      'bookingId': bookingId.trim(),
      'furnitureId': furnitureId.trim(),
      'customerId': customerId.trim(),
      'type': type.name,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status.name,
      'assignedStaffId': assignedStaffId?.trim(),
      'notes': notes?.trim(),
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Reconstruct a delivery from Firestore document data.
  factory Delivery.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return Delivery(
      id: documentId,
      bookingId: _requiredString(map, 'bookingId'),
      furnitureId: _requiredString(map, 'furnitureId'),
      customerId: _requiredString(map, 'customerId'),
      type: DeliveryType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => DeliveryType.delivery,
      ),
      scheduledAt: _readDate(map['scheduledAt']),
      status: DeliveryStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => DeliveryStatus.scheduled,
      ),
      assignedStaffId: _optionalString(map['assignedStaffId']),
      notes: _optionalString(map['notes']),
      createdAt: _optionalDate(map['createdAt']),
      updatedAt: _optionalDate(map['updatedAt']),
    );
  }

  factory Delivery.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw FormatException(
        'Delivery document ${document.id} has no data.',
      );
    }

    return Delivery.fromMap(document.id, data);
  }

  static String _requiredString(
    Map<String, dynamic> map,
    String field,
  ) {
    final value = map[field];

    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
        'Delivery field "$field" is missing or invalid.',
      );
    }

    return value.trim();
  }

  static String? _optionalString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    throw const FormatException(
      'Delivery scheduledAt is missing or invalid.',
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
