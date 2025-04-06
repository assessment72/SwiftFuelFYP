import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fuel_delivery_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Customer login flow test", (WidgetTester tester) async {
    await Firebase.initializeApp();

    // Launch the app
    app.main();
    await tester.pumpAndSettle();

    // Locate the text fields by their keys
    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.text('Login');

    // Enter test credentials
    await tester.enterText(emailField, 'fahad.riaz22@hotmail.com');
    await tester.enterText(passwordField, 'fahad1122');

    // Tap the login button
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that the HomeScreen has loaded
    expect(find.text('Order Fuel'), findsOneWidget);  });
}
