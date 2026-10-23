import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seat_and_set/admin_panel/models/inventory_item.dart';
import 'package:seat_and_set/admin_panel/services/inventory_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late InventoryService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = InventoryService(firestore: firestore);
  });

  InventoryItem item({
    String id = '',
    String sku = 'SFA001',
    InventoryStatus status = InventoryStatus.available,
  }) {
    return InventoryItem(
      id: id,
      name: 'Modern Sofa',
      sku: sku,
      status: status,
      type: FurnitureType.sofa,
    );
  }

  test('creates, reads, updates, and deletes furniture', () async {
    final id = await service.addFurniture(item());
    final created = await service.getFurniture();

    expect(id, 'SFA001');
    expect(created.single.name, 'Modern Sofa');
    expect(created.single.status, InventoryStatus.available);

    await service.updateFurnitureStatus(id, InventoryStatus.rented);
    expect((await service.getFurniture()).single.status, InventoryStatus.rented);

    await service.deleteFurniture(id);
    expect(await service.getFurniture(), isEmpty);
  });

  test('rejects duplicate furniture SKUs', () async {
    final firstId = await service.addFurniture(item());
    await service.addFurniture(item(sku: 'SFA002'));

    expect(
      () => service.addFurniture(item()),
      throwsA(isA<StateError>()),
    );

    expect(
      () => service.updateFurniture(item(id: firstId, sku: 'SFA002')),
      throwsA(isA<StateError>()),
    );
  });

  test('real-time stream reflects furniture changes', () async {
    final stream = service.watchFurniture();
    final first = expectLater(
      stream,
      emitsThrough(predicate<List<InventoryItem>>(
        (items) => items.length == 1 && items.single.sku == 'SFA001',
      )),
    );

    await service.addFurniture(item());
    await first;
  });
}
