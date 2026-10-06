import 'package:flutter_test/flutter_test.dart';
import 'package:seat_and_set/main.dart';

void main() {
  testWidgets('Admin Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SeatAndSetAdminApp());
    expect(find.text('Seat and Set'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Operations at your fingertips'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
