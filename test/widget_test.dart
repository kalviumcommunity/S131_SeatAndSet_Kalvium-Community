// Smoke test for the Seat & Set app's initial navigation flow.
//
// Verifies the app boots into the onboarding screen, and that "Skip"
// navigates on to Sign In — the first real interaction a user has with
// the app.

import 'package:flutter_test/flutter_test.dart';

import 'package:seat_and_set/main.dart';

void main() {
  testWidgets('App starts on onboarding and Skip leads to Sign In', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SeatAndSetApp());
    await tester.pumpAndSettle();

    // Onboarding screen is shown first, with its "Skip" button.
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Welcome Back'), findsNothing);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    // Skipping onboarding lands on Sign In.
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
