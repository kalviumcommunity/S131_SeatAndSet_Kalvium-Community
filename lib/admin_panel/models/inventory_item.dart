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
