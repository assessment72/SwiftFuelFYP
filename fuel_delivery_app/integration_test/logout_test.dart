import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fuel_delivery_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Logout flow test", (WidgetTester tester) async {
    await Firebase.initializeApp();
    app.main();
    await tester.pumpAndSettle();

    // Login first
    await tester.enterText(find.byKey(const Key('emailField')), 'fahad.riaz22@hotmail.com');
    await tester.enterText(find.byKey(const Key('passwordField')), 'fahad1122');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Tap logout icon
    await tester.tap(find.byKey(const Key('logoutButton')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Check that we're back on the login screen
    expect(find.text('Login'), findsOneWidget);
  });
}
