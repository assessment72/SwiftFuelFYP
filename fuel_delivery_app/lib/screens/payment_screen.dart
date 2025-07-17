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

  Future<void> makePayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a payment method.')));
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid payment method selected.')));
    }
  }

  Future<void> _makeStripePayment() async {
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

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!')));

      // Navigate to Order Confirmation Page
      Navigator.pop(context, true); // Return true for successful payment
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: $e')));
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
    // TODO: Implement Moyasar payment logic here
    // This will involve using the Moyasar SDK to initiate a payment.
    // You will need to provide your Moyasar Publishable API Key.
    // Example (conceptual):
    // final result = await Moyasar.instance.startPayment(
    //   amount: (widget.amount * 100).toInt(), // Amount in smallest currency unit
    //   currency: 'SAR',
    //   description: 'Fuel Order',
    //   publishableApiKey: 'YOUR_MOYASAR_PUBLISHABLE_API_KEY',
    //   // ... other parameters like payment methods (mada, credit card, stc pay)
    // );
    // if (result.status == PaymentStatus.paid) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moyasar Payment Successful!')));
    //   Navigator.pop(context, true);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moyasar Payment Failed: ${result.message}')));
    // }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moyasar payment integration is not yet complete.')));
  }

  Future<void> _makeHyperPayPayment() async {
    // TODO: Implement HyperPay payment logic here
    // This will involve using the HyperPay SDK to initiate a payment.
    // HyperPay often requires a backend integration to create checkout IDs.
    // Example (conceptual):
    // final checkoutId = await _createHyperPayCheckoutId(); // Call your backend to get checkout ID
    // final result = await Hyperpay.instance.startPayment(
    //   checkoutId: checkoutId,
    //   // ... other parameters
    // );
    // if (result.status == HyperpayPaymentStatus.success) {
    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('HyperPay Payment Successful!')));
    //   Navigator.pop(context, true);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('HyperPay Payment Failed: ${result.message}')));
    // }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('HyperPay payment integration is not yet complete.')));
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
              // Payment Icon
              const Icon(Icons.payment, size: 100, color: Colors.black),
              const SizedBox(height: 20),

              // Payment Amount
              Text(
                'Total Amount: SAR ${widget.amount.toStringAsFixed(2)}', // Changed currency symbol
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Payment Method Selection
              DropdownButton<String>(
                hint: const Text('Select Payment Method'),
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
                    child: Text(value),
                  );
                }).toList(),
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


