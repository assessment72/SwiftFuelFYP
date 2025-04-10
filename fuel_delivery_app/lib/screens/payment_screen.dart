/// Author: Fahad Riaz
/// Description: This screen handles the payment process in the SwiftFuel app using Stripe integration.
/// It creates a payment intent, initializes the Stripe payment sheet, and allows users to complete transactions.
/// The screen dynamically displays the amount based on the fuel order and provides user feedback on payment status.





import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fuel_delivery_app/screens/fuelordering_screen.dart';


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

  Future<void> makePayment() async {
    try {
      // Step 1: Create Payment Intent on the Server
      paymentIntent = await createPaymentIntent(widget.amount.toString(), 'gbp');

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'SwiftFuel',
        ),
      );

      // Step 3: Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));

      // Navigate to Order Confirmation Page
      Navigator.pop(context, true); // Return true for successful payment
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: $e')));
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      // Stripe API Secret Key
      const String secretKey = 'sk_test_51QvWmxLdbeQ0UiZd848BShgU6UUG53Is4KznCFh8qxpyVQ0Cbn9l5eAvNDi25uaDG90QXlP0VckstwBqEwihE0IR00kVM7zi4N';

      // Convert amount to smallest currency unit (e.g., cents for USD)
      int amountInCents = (double.parse(amount) * 100).toInt();

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': currency,
        },
      );

      return jsonDecode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Payment",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
              // Stripe Logo
              Image.asset(
                'assets/stripelogo.png',
                height: 80,
              ),
              const SizedBox(height: 20),

              // Payment Icon
              const Icon(Icons.payment, size: 100, color: Colors.black),
              const SizedBox(height: 20),

              // Payment Amount
              Text(
                'Total Amount: \£${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Proceed to Pay Button
              ElevatedButton(
                onPressed: () => makePayment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 50.0,
                  ),
                ),
                child: const Text(
                  'Proceed to Pay',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
