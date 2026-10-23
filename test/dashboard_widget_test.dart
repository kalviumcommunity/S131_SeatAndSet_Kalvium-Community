import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seat_and_set/admin_panel/screens/admin_dashboard_screen.dart';
import 'package:seat_and_set/admin_panel/services/inventory_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dashboard displays live inventory metrics', (tester) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('furniture').doc('sofa-1').set({
      'name': 'Modern Sofa',
      'sku': 'SFA001',
      'status': 'rented',
      'type': 'sofa',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    await firestore.collection('furniture').doc('table-1').set({
      'name': 'Study Table',
      'sku': 'TBL001',
      'status': 'available',
      'type': 'studyTable',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    await firestore.collection('furniture').doc('chair-1').set({
      'name': 'Office Chair',
      'sku': 'CHR001',
      'status': 'inTransit',
      'type': 'officeChair',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });

    await tester.pumpWidget(
      MaterialApp(
        home: AdminDashboardScreen(
          inventoryService: InventoryService(firestore: firestore),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('Total Items')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('Rented')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('Available')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('In Transit')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(find.text('Today (placeholder)'), findsOneWidget);
    expect(find.text('Recent Activity (placeholder)'), findsOneWidget);
  });
}
