import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_and_set/main.dart';
import 'package:seat_and_set/admin_panel/screens/admin_inventory_screen.dart';

void main() {
  testWidgets('Admin Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SeatAndSetAdminApp());
    expect(find.text('Seat and Set'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Operations at your fingertips'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Admin Inventory screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AdminInventoryScreen(),
      ),
    );
    expect(find.text('Inventory'), findsWidgets);
    expect(find.text('Modern Sofa'), findsOneWidget);
    expect(find.text('Study Table'), findsOneWidget);
    expect(find.text('Office Chair'), findsOneWidget);
  });
}
