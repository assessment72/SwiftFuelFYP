/// Author: Fahad Riaz
/// Description: This is the main entry point of the SwiftFuel app. It initializes Firebase,
/// sets up Stripe payment integration, and defines the main routes for navigation
/// across the app such as login, registration, home, and fuel ordering screens.
/// This file ensures the app is properly bootstrapped with necessary configurations.



import 'package:flutter/material.dart';
import 'package:fuel_delivery_app/screens/fuelordering_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fuel_delivery_app/generated/app_localizations.dart';
import 'package:fuel_delivery_app/screens/support_chat_screen.dart';
import 'package:fuel_delivery_app/screens/promotions_screen.dart';
import 'package:fuel_delivery_app/services/notification_service.dart';


