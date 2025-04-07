import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:fuel_delivery_app/screens/payment_screen.dart';
import 'package:fuel_delivery_app/screens/ordertracking_screen.dart';

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
    if (_selectedFuelType.value == null || _selectedLocation.value == null || _vehicleNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a location')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Your Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🚗 Vehicle: ${_vehicleNumberController.text}'),
              const SizedBox(height: 8),
              Text('⛽ Fuel Type: ${_selectedFuelType.value}'),
              const SizedBox(height: 8),
              Text('📍 Location: (${_selectedLocation.value!.latitude.toStringAsFixed(6)}, ${_selectedLocation.value!.longitude.toStringAsFixed(6)})'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _placeOrder();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedFuelType.value == null || _selectedLocation.value == null || _vehicleNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a location')),
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
          const SnackBar(content: Text('Order placed successfully')),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        title: const Text(
          'Order Fuel',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            const Padding(
            padding: EdgeInsets.only(bottom: 10, top: 10),
            child: Text(
              "Select Your Location",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
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
                        border: Border.all(color: Colors.pink.shade200),
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
                    return _buildDropdown(fuelType);
                  },
                ),
                const SizedBox(height: 20),

                _buildTextField(_vehicleNumberController, 'Vehicle Number Plate', key: const Key('vehicleField')),
                const SizedBox(height: 20),

                ElevatedButton(
                  key: const Key('placeOrderButton'),
                  onPressed: _showOrderConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
                    child: Text('Place Order', style: TextStyle(fontSize: 18)),
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

  Widget _buildDropdown(String? fuelType) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: DropdownButtonFormField<String>(
        key: const Key('fuelDropdown'),
        value: fuelType,
        hint: const Text(
          "Select Fuel Type",
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
        items: ['Petrol', 'Diesel', 'Premium']
            .map((fuel) => DropdownMenuItem(
          value: fuel,
          child: Text(
            fuel,
            style: const TextStyle(fontSize: 16),
          ),
        ))
            .toList(),
        onChanged: (value) => _selectedFuelType.value = value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
        dropdownColor: Colors.white,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String hint, {Key? key}) {
    return TextField(key: key, controller: controller, decoration: InputDecoration(hintText: hint));
  }
}
