
import 'package:cloud_firestore/cloud_firestore.dart';

enum InventoryStatus {
  rented,
  available,
  inTransit,
}

enum FurnitureType {
  sofa,
  studyTable,
  officeChair,
  bed,
  diningTable,
}

class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final InventoryStatus status;
  final FurnitureType type;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.status,
    required this.type,
  });

  String get statusLabel {
    switch (status) {
      case InventoryStatus.rented:
        return 'Rented';
      case InventoryStatus.available:
        return 'Available';
      case InventoryStatus.inTransit:
        return 'In Transit';
    }
  }

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    return name.toLowerCase().contains(query) || sku.toLowerCase().contains(query);
  }

  /// Convert this item into a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'status': status.name,
      'type': type.name,
    };
  }

  /// Create an item from a Firestore document.
  factory InventoryItem.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return InventoryItem(
      id: documentId,
      name: _readRequiredString(map, 'name'),
      sku: _readRequiredString(map, 'sku'),
      status: InventoryStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => InventoryStatus.available,
      ),
      type: FurnitureType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => FurnitureType.sofa,
      ),
    );
  }

  /// Create an item directly from a Firestore document snapshot.
  factory InventoryItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw FormatException(
        'Furniture document ${document.id} has no data.',
      );
    }

    return InventoryItem.fromMap(document.id, data);
  }

  static String _readRequiredString(
    Map<String, dynamic> map,
    String field,
  ) {
    final value = map[field];

    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
        'Furniture field "$field" is missing or invalid.',
      );
    }

    return value.trim();
  }

  /// Existing mock data retained for the current UI.
  static List<InventoryItem> get mockItems => const [
        InventoryItem(
          id: '1',
          name: 'Modern Sofa',
          sku: 'SFA001',
          status: InventoryStatus.rented,
          type: FurnitureType.sofa,
        ),
        InventoryItem(
          id: '2',
          name: 'Study Table',
          sku: 'TBL002',
          status: InventoryStatus.available,
          type: FurnitureType.studyTable,
        ),
        InventoryItem(
          id: '3',
          name: 'Office Chair',
          sku: 'CHR003',
          status: InventoryStatus.inTransit,
          type: FurnitureType.officeChair,
        ),
        InventoryItem(
          id: '4',
          name: 'King Size Bed',
          sku: 'BED004',
          status: InventoryStatus.rented,
          type: FurnitureType.bed,
        ),
        InventoryItem(
          id: '5',
          name: 'Dining Table',
          sku: 'TBL005',
          status: InventoryStatus.available,
          type: FurnitureType.diningTable,
        ),
      ];
}
