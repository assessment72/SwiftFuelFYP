/// Author: Fahad Riaz
/// Description: This is the main entry point of the SwiftFuel app. It initializes Firebase,
/// sets up Stripe payment integration, requests notification permissions,
/// and defines the main routes for navigation across the app such as login,
/// registration, home, notifications, orders, and account screens.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

// Screens
import 'package:fuel_delivery_app/screens/login_screen.dart';
import 'package:fuel_delivery_app/screens/register_screen.dart';
import 'package:fuel_delivery_app/screens/home_screen.dart';
import 'package:fuel_delivery_app/screens/fuelordering_screen.dart';
import 'package:fuel_delivery_app/screens/notifications_screen.dart';
import 'package:fuel_delivery_app/screens/pastorders_screen.dart';
import 'package:fuel_delivery_app/screens/user_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();

  // ✅ Setup Stripe
  Stripe.publishableKey =
      "pk_test_51QvWmxLdbeQ0UiZd1jqwZ2vPWtDNJqVAi3advQvTrixYOZYDxmBVDTpdxIaN9C01HddNAbTeEtrsMMOcLTvjlygO00dGcWbyqv";

  // ✅ Request notification permissions (especially for iOS)
  await FirebaseMessaging.instance.requestPermission();

  // ✅ Get FCM token for testing
  final token = await FirebaseMessaging.instance.getToken();
  print("🔐 FCM Token: $token");

  runApp(const SwiftFuelApp());
}

class SwiftFuelApp extends StatelessWidget {
  const SwiftFuelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftFuel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/orderfuel': (context) => FuelOrderingScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/orders': (context) => PastOrdersScreen(),
        '/account': (context) => const UserProfileScreen(),
      },
    );
  }
}
