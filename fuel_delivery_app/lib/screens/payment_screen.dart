/// Author: Fahad Riaz
/// Description: This screen handles the payment process in the SwiftFuel app using Stripe integration.
/// It creates a payment intent, initializes the Stripe payment sheet, and allows users to complete transactions.
/// The screen dynamically displays the amount based on the fuel order and provides user feedback on payment status.





import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fuel_delivery_app/screens/fuelordering_screen.dart';
import 'package:moyasar/moyasar.dart'; // Import Moyasar
import 'package:hyperpay_flutter/hyperpay_flutter.dart'; // Import HyperPay
import 'package:fuel_delivery_app/generated/app_localizations.dart';


class PaymentScreen extends StatefulWidget {
  final String fuelType;
  final String vehicleNumber;
  final double amount; // Amount for fuel order

  PaymentScreen({required this.fuelType, required this.vehicleNumber, required this.amount});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Map<String, dynamic>? paymentIntent;
  String? _selectedPaymentMethod; // To hold the selected payment method

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = 'Stripe'; // Default to Stripe
  }

  Future<void> makePayment() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.selectPaymentMethod)));
      return;
    }

    switch (_selectedPaymentMethod) {
      case 'Stripe':
        await _makeStripePayment();
        break;
      case 'Moyasar':
        await _makeMoyasarPayment();
        break;
      case 'HyperPay':
        await _makeHyperPayPayment();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.invalidPaymentMethod)));
    }
  }

  Future<void> _makeStripePayment() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    try {
      // Step 1: Create Payment Intent on the Server
      // Changed currency to 'sar' for Saudi Riyal
      paymentIntent = await _createStripePaymentIntent(widget.amount.toString(), 'sar');

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'SwiftFuel',
          // Add billing details collection if needed for SAR payments
          // billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
          //   emailCollectionMode: CollectionMode.always,
          //   addressCollectionMode: AddressCollectionMode.full,
          // ),
        ),
      );

      // Step 3: Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.paymentSuccessful)));

      // Navigate to Order Confirmation Page
      Navigator.pop(context, true); // Return true for successful payment
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${localizations.paymentFailed}: $e')));
    }
  }

  Future<Map<String, dynamic>> _createStripePaymentIntent(String amount, String currency) async {
    try {
      // Stripe API Secret Key
      // NOTE: In a production environment, this secret key should NEVER be exposed in client-side code.
      // It should be handled securely on a backend server.
      const String secretKey = 'sk_test_51QvWmxLdbeQ0UiZd848BShgU6UUG53Is4KznCFh8qxpyVQ0Cbn9l5eAvNDi25uaDG90QXlP0VckstwBqEwihE0IR00kVM7zi4N';

      // Convert amount to smallest currency unit (e.g., halalas for SAR)
      int amountInSmallestUnit = (double.parse(amount) * 100).toInt();

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': amountInSmallestUnit.toString(),
          'currency': currency,
        },
      );

      return jsonDecode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> _makeMoyasarPayment() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    try {
      // Replace with your actual Moyasar Publishable API Key
      const String moyasarPublishableApiKey = 'pk_test_YOUR_MOYASAR_PUBLISHABLE_API_KEY';

      final result = await Moyasar.instance.startPayment(
        amount: (widget.amount * 100).toInt(), // Amount in smallest currency unit (halalas)
        currency: 'SAR',
        description: 'Fuel Order from SwiftFuel',
        publishableApiKey: moyasarPublishableApiKey,
        // You can specify payment methods here. Moyasar supports Mada, Credit Card, STC Pay.
        // For example:
        // paymentMethods: [PaymentMethod.mada, PaymentMethod.creditCard, PaymentMethod.stcPay],
      );

      if (result.status == PaymentStatus.paid) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.moyasarPaymentSuccessful)));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${localizations.moyasarPaymentFailed}: ${result.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${localizations.moyasarPaymentFailed}: $e')));
    }
  }

  Future<void> _makeHyperPayPayment() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    try {
      // HyperPay usually requires a backend integration to create a checkout ID.
      // This is a placeholder. You'll need to implement a backend endpoint
      // that calls HyperPay's API to get a checkout ID.
      // Example:
      // final String checkoutId = await _getHyperPayCheckoutIdFromBackend();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.hyperPayBackendRequired)));
      // For now, we'll just show a message.
      // If you have a checkout ID, you would proceed like this:
      // final result = await Hyperpay.instance.startPayment(
      //   checkoutId: checkoutId,
      //   // ... other parameters like payment brand (VISA, MADA, etc.)
      // );
      // if (result.status == HyperpayPaymentStatus.success) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.hyperPayPaymentSuccessful)));
      //   Navigator.pop(context, true);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${localizations.hyperPayPaymentFailed}: ${result.message}')));
      // }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${localizations.hyperPayPaymentFailed}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          localizations.payment,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FuelOrderingScreen()),
            );
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Payment Icon
              Icon(Icons.payment, size: 100, color: Theme.of(context).iconTheme.color),
              const SizedBox(height: 20),

              // Payment Amount
              Text(
                '${localizations.totalAmount}: SAR ${widget.amount.toStringAsFixed(2)}', // Changed currency symbol
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Payment Method Selection
              DropdownButton<String>(
                hint: Text(localizations.selectPaymentMethod),
                value: _selectedPaymentMethod,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                },
                items: <String>['Stripe', 'Moyasar', 'HyperPay']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  );
                }).toList(),
                dropdownColor: Theme.of(context).cardColor,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 20),

              // Proceed to Pay Button
              ElevatedButton(
                onPressed: () => makePayment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 50.0,
                  ),
                ),
                child: Text(
                  localizations.proceedToPay,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}


