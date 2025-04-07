import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fuel_delivery_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Update password flow test", (WidgetTester tester) async {
    await Firebase.initializeApp();
    app.main();
    await tester.pumpAndSettle();

    const testEmail = 'fahad.adil666@gmail.com';
    const originalPassword = 'fahad1122';
    const newPassword = 'fahad1144';

    // Step 1: Login using current password
    await tester.enterText(find.byKey(const Key('emailField')), testEmail);
    await tester.enterText(find.byKey(const Key('passwordField')), originalPassword);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Step 2: Navigate to Account tab
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle();

    // Step 3: Update password to a new one
    await tester.enterText(find.byKey(const Key('passwordField')), newPassword);
    await tester.tap(find.byKey(const Key('updatePasswordButton')));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Step 4: Verify success
    expect(find.textContaining('Password updated successfully'), findsOneWidget);

    // Step 5: Revert password back to original
    await FirebaseAuth.instance.currentUser?.updatePassword(originalPassword);
  });
}
