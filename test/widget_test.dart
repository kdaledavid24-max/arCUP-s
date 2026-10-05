import 'package:flutter_test/flutter_test.dart';
import 'package:arcups_app/main.dart';

void main() {
  testWidgets('App smoke test - Food Ordering loads properly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodOrderingApp());

    // Verify that the splash screen shows Food Ordering
    expect(find.text('Food Ordering'), findsOneWidget);

    // Let the timer elapse to navigate to home
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify that the Home screen loaded with store hours and header
    expect(find.text('WE ARE OPEN FROM'), findsOneWidget);
    expect(find.text('OPEN DAILY ( MONDAY - SUNDAY )'), findsOneWidget);
  });
}
