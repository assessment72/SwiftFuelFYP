import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fuel_delivery_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Customer registration flow test", (WidgetTester tester) async {
    await Firebase.initializeApp();
    app.main();
    await tester.pumpAndSettle();

    // Go to register screen
    final goToRegister = find.text("Don't have an account? Create here");
    expect(goToRegister, findsOneWidget);
    await tester.tap(goToRegister);
    await tester.pumpAndSettle();

    // Fill out the registration form
    final emailField = find.byKey(const Key('regEmailField'));
    final passwordField = find.byKey(const Key('regPasswordField'));
    final mobileField = find.byKey(const Key('regMobileField'));
    final registerButton = find.byKey(const Key('registerButton'));

    final String testEmail = "testuser${DateTime.now().millisecondsSinceEpoch}@example.com";

    await tester.enterText(emailField, testEmail);
    await tester.enterText(passwordField, "Test1234");
    await tester.enterText(mobileField, "7123456789");

    // Submit registration
    await tester.tap(registerButton);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify we're redirected to login screen
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
