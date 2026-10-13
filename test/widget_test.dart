import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_and_set/main.dart';
import 'package:seat_and_set/admin_panel/screens/admin_orders_screen.dart';

void main() {
  testWidgets('Admin Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SeatAndSetAdminApp());
    expect(find.text('Seat and Set'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Operations at your fingertips'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Admin Orders (Deliveries & Pickups) screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminOrdersScreen(),
      ),
    );
    expect(find.text('Deliveries & Pickups'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Modern Sofa'), findsOneWidget);
    expect(find.text('Study Table'), findsOneWidget);
    expect(find.text('Dining Set'), findsOneWidget);
    expect(find.text('Office Chair'), findsOneWidget);
    expect(find.text('Navigate'), findsNWidgets(4));

    // Tap Upcoming tab
    await tester.tap(find.text('Upcoming'));
    await tester.pumpAndSettle();
    expect(find.text('King Size Bed'), findsOneWidget);

    // Tap Completed tab
    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.text('Lounge Armchair'), findsOneWidget);
  });
}
