import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fuel_delivery_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Fuel ordering flow test", (WidgetTester tester) async {
    await Firebase.initializeApp();
    app.main();
    await tester.pumpAndSettle();

    // 1. Login with test user
    await tester.enterText(find.byKey(const Key('emailField')), 'fahad.riaz22@hotmail.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'fahad1122');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 2. Navigate to Order Fuel screen by tapping "Order Fuel" button
    await tester.tap(find.byKey(const Key('orderFuelButton')));
    await tester.pumpAndSettle();

    // 3. Select fuel type
    await tester.tap(find.byKey(const Key('fuelDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Petrol').last);
    await tester.pumpAndSettle();

    // 4. Enter vehicle number
    await tester.enterText(find.byKey(const Key('vehicleField')), 'ABC123');

    // 5. Tap on "Place Order"
    await tester.tap(find.byKey(const Key('placeOrderButton')));
    await tester.pumpAndSettle();

    // 6. Confirm Order in Dialog
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 7. Verify navigation to Payment screen
    expect(find.textContaining('Payment'), findsOneWidget);
  });
}
