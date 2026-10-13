import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:seat_and_set/admin_panel/screens/admin_inventory_screen.dart';
import 'package:seat_and_set/admin_panel/services/inventory_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Admin Inventory screen smoke test', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final inventoryService = InventoryService(
      firestore: firestore,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AdminInventoryScreen(
          inventoryService: inventoryService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Inventory'), findsWidgets);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Search items...'), findsOneWidget);
    expect(
      find.textContaining('No furniture has been added yet.'),
      findsOneWidget,
    );
  });
}