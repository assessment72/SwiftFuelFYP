/// Author: Fahad Riaz
/// Description: This file implements the Fuel Ordering Screen of the SwiftFuel app. It allows users to select a fuel type,
/// input their vehicle number plate, and choose a delivery location using an interactive Google Map. Upon order confirmation,
/// users are directed to the Stripe-powered payment system, and after successful payment, an order is created and sent to Firebase
/// for further tracking and management.





import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:fuel_delivery_app/screens/payment_screen.dart';
import 'package:fuel_delivery_app/screens/ordertracking_screen.dart';
import 'package:fuel_delivery_app/generated/app_localizations.dart';

class FuelOrderingScreen extends StatefulWidget {
  @override
  _FuelOrderingScreenState createState() => _FuelOrderingScreenState();
}

class _FuelOrderingScreenState extends State<FuelOrderingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _vehicleNumberController = TextEditingController();
  final ValueNotifier<String?> _selectedFuelType = ValueNotifier<String?>(null);
  final ValueNotifier<LatLng?> _selectedLocation = ValueNotifier<LatLng?>(null);

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getUserCurrentLocation();
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _selectedFuelType.dispose();
    _selectedLocation.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getUserCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    LocationData _locationData = await location.getLocation();
    _selectedLocation.value = LatLng(_locationData.latitude!, _locationData.longitude!);

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _selectedLocation.value!, zoom: 15),
      ),
    );
  }

  Future<void> _showOrderConfirmation() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    if (_selectedFuelType.value == null || _selectedLocation.value == null || _vehicleNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.fillAllFields)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmYourOrder),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${localizations.vehicle}: ${_vehicleNumberController.text}'),
              const SizedBox(height: 8),
              Text('${localizations.fuelType}: ${_selectedFuelType.value}'),
              const SizedBox(height: 8),
              Text('${localizations.location}: (${_selectedLocation.value!.latitude.toStringAsFixed(6)}, ${_selectedLocation.value!.longitude.toStringAsFixed(6)})'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _placeOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(localizations.confirm),
            ),
          ],
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    if (_selectedFuelType.value == null || _selectedLocation.value == null || _vehicleNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.fillAllFields)),
      );
      return;
    }

    double orderAmount = 50.0;
    bool paymentSuccessful = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          fuelType: _selectedFuelType.value!,
          vehicleNumber: _vehicleNumberController.text,
          amount: orderAmount,
        ),
      ),
    );

    if (paymentSuccessful) {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentReference orderRef = await _firestore.collection('orders').add({
          'userId': user.uid,
          'fuelType': _selectedFuelType.value,
          'vehicleNumber': _vehicleNumberController.text,
          'location': GeoPoint(_selectedLocation.value!.latitude, _selectedLocation.value!.longitude),
          'orderedAt': Timestamp.now(),
          'status': 'Pending',
          'assignedDriverId': null,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.orderPlacedSuccessfully)),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: orderRef.id),
          ),
        );
      }
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
        title: Text(
          localizations.orderFuel,
          style: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle?.color, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
            Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 10),
            child: Text(
              localizations.selectYourLocation,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            ),
                ValueListenableBuilder<LatLng?>(
                  valueListenable: _selectedLocation,
                  builder: (context, location, _) {
                    return Container(
                      height: 300,
                      margin: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Theme.of(context).colorScheme.secondary),
                      ),
                    child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                      child: location == null
                          ? const Center(child: CircularProgressIndicator())
                          : GoogleMap(
                        initialCameraPosition: CameraPosition(target: location, zoom: 15),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _getUserCurrentLocation();
                        },
                        onTap: (LatLng loc) {
                          _selectedLocation.value = loc;
                        },
                        markers: location != null
                            ? {
                          Marker(markerId: const MarkerId("selected-location"), position: location),
                        }
                            : {},
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
                    )
                    );
                  },
                ),
                const SizedBox(height: 20),

                ValueListenableBuilder<String?>(
                  valueListenable: _selectedFuelType,
                  builder: (context, fuelType, _) {
                    return _buildDropdown(fuelType, localizations);
                  },\n                ),
                const SizedBox(height: 20),

                _buildTextField(_vehicleNumberController, localizations.vehicleNumberPlate, key: const Key('vehicleField')),
                const SizedBox(height: 20),

                ElevatedButton(
                  key: const Key('placeOrderButton'),
                  onPressed: _showOrderConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                    child: Text(localizations.placeOrder, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String? fuelType, AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: DropdownButtonFormField<String>(
        key: const Key('fuelDropdown'),
        value: fuelType,
        hint: Text(
          localizations.selectFuelType,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
        ),
        items: [localizations.petrol, localizations.diesel, localizations.premium]
            .map((fuel) => DropdownMenuItem(
          value: fuel,
          child: Text(
            fuel,
            style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ))
            .toList(),
        onChanged: (value) => _selectedFuelType.value = value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
        ),
        icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).iconTheme.color),
        dropdownColor: Theme.of(context).cardColor,
        style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String hint, {Key? key}) {
    return TextField(
      key: key,
      controller: controller,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
      ),
    );
  }
}


