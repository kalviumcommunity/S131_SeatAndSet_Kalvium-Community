import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seat_and_set/admin_panel/screens/admin_inventory_screen.dart';
import 'package:seat_and_set/admin_panel/screens/admin_login_screen.dart';
import 'package:seat_and_set/admin_panel/screens/admin_orders_screen.dart';
import 'package:seat_and_set/admin_panel/screens/admin_customers_screen.dart';
import 'package:seat_and_set/admin_panel/screens/admin_reports_screen.dart';
import 'package:seat_and_set/admin_panel/screens/admin_shell_screen.dart';
import 'package:seat_and_set/admin_panel/services/inventory_service.dart';
import 'package:seat_and_set/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Admin Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SeatAndSetAdminApp(home: AdminLoginScreen()));
    expect(find.text('Seat and Set'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Operations at your fingertips'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

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

  testWidgets('Admin Customers screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminCustomersScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Check title and search bar
    expect(find.text('Customers'), findsWidgets);
    expect(find.text('Search customers...'), findsOneWidget);

    // Check customer names from Figma mockup
    expect(find.text('Rahul Sharma'), findsOneWidget);
    expect(find.text('+91 98765 43210'), findsOneWidget);
    expect(find.text('12 active rentals'), findsOneWidget);
    expect(find.text('RS'), findsOneWidget);

    expect(find.text('Priya Mehta'), findsOneWidget);
    expect(find.text('+91 87654 32109'), findsOneWidget);
    expect(find.text('3 active rentals'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);

    expect(find.text('Arjun Singh'), findsOneWidget);
    expect(find.text('+91 76543 21098'), findsOneWidget);
    expect(find.text('1 active rental'), findsOneWidget);
    expect(find.text('AS'), findsOneWidget);

    expect(find.text('Neha Kapoor'), findsOneWidget);
    expect(find.text('2 active rentals'), findsWidgets);
    expect(find.text('NK'), findsOneWidget);

    expect(find.text('Vikram Raina'), findsOneWidget);
    expect(find.text('No active rentals'), findsWidgets);
    expect(find.text('VR'), findsOneWidget);

    // Test search filter
    await tester.enterText(find.byType(TextField), 'Priya');
    await tester.pumpAndSettle();
    expect(find.text('Priya Mehta'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsNothing);

    // Clear search
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Rahul Sharma'), findsOneWidget);

    // Tap customer card to open details modal
    await tester.tap(find.text('Rahul Sharma'));
    await tester.pumpAndSettle();
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
  });

  testWidgets('Admin Reports screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminReportsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Check title and timeframe selector
    expect(find.text('Reports'), findsWidgets);
    expect(find.text('This Month'), findsOneWidget);

    // Check Metric 1: Total Revenue
    expect(find.text('₹1,24,800'), findsOneWidget);
    expect(find.text('+12%'), findsOneWidget);
    expect(find.text('Total Revenue'), findsOneWidget);

    // Check Metric 2: Total Rentals
    expect(find.text('86'), findsOneWidget);
    expect(find.text('+8%'), findsOneWidget);
    expect(find.text('Total Rentals'), findsOneWidget);

    // Check Rentals Trend section & labels
    expect(find.text('Rentals Trend'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('40'), findsOneWidget);
    expect(find.text('20'), findsNWidgets(2)); // Y-axis 20 and X-axis 20
    expect(find.text('0'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('05'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    // Check Top Categories section & counts
    expect(find.text('Top Categories'), findsOneWidget);
    expect(find.text('Sofas'), findsOneWidget);
    expect(find.text('32'), findsOneWidget);
    expect(find.text('Tables'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('Chairs'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Beds'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    // Test Timeframe switching (tap This Month -> choose This Week)
    await tester.tap(find.text('This Month'));
    await tester.pumpAndSettle();
    expect(find.text('Select Timeframe'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);

    await tester.tap(find.text('This Week'));
    await tester.pumpAndSettle();

    // Verify updated values for This Week
    expect(find.text('₹34,200'), findsOneWidget);
    expect(find.text('24'), findsWidgets);
  });

  testWidgets('Admin Navigation Shell smoke test with state preservation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final fakeFirestore = FakeFirebaseFirestore();
    final fakeInventoryService = InventoryService(firestore: fakeFirestore);

    await tester.pumpWidget(
      MaterialApp(
        home: AdminShellScreen(
          initialIndex: 0,
          inventoryService: fakeInventoryService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Dashboard tab active by default
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Total Items'), findsOneWidget);

    // Switch to Orders (tab 2)
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('Deliveries & Pickups'), findsOneWidget);

    // Switch to Customers (tab 3)
    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();
    expect(find.text('Search customers...'), findsOneWidget);

    // Filter customers
    await tester.enterText(find.byType(TextField), 'Priya');
    await tester.pumpAndSettle();
    expect(find.text('Priya Mehta'), findsOneWidget);

    // Switch to Reports (tab 4) and switch back to Customers (tab 3)
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Rentals Trend'), findsOneWidget);

    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();

    // State preservation verified: query 'Priya' is still preserved!
    expect(find.text('Priya Mehta'), findsOneWidget);
    expect(find.text('Rahul Sharma'), findsNothing);
  });
}