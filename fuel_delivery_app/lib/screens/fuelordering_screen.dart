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

  String? _selectedFuelType;
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getUserCurrentLocation();
  }

  Future<void> _getUserCurrentLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    // Check if location service is enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check location permission
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get user location
    _locationData = await location.getLocation();
    setState(() {
      _selectedLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
    });

    // Move the camera to the user's current location
    if (_mapController != null && _selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selectedLocation!, zoom: 15),
        ),
      );
    }
  }

  Future<void> _showOrderConfirmation() async {
    if (_selectedFuelType == null || _selectedLocation == null || _vehicleNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select location')),
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
              Text('Fuel Type: $_selectedFuelType'),
              const SizedBox(height: 10),
              Text('Vehicle Number: ${_vehicleNumberController.text}'),
              const SizedBox(height: 10),
              Text('Location: (${_selectedLocation!.latitude}, ${_selectedLocation!.longitude})'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 25.0,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _placeOrder();
              },
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
                'Confirm',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],

        );
      },
    );
  }

  Future<void> _placeOrder() async {
    if (_selectedFuelType == null || _selectedLocation == null || _vehicleNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select location')),
      );
      return;
    }

    // Set Order Amount
    double orderAmount = 50.0;

    // Navigate to Payment Screen
    bool paymentSuccessful = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          fuelType: _selectedFuelType!,
          vehicleNumber: _vehicleNumberController.text,
          amount: orderAmount,
        ),
      ),
    );

    if (paymentSuccessful == true) {
      User? user = _auth.currentUser;
      if (user != null) {
        // Save Order to Firestore
        DocumentReference orderRef = await _firestore.collection('orders').add({
          'userId': user.uid,
          'fuelType': _selectedFuelType,
          'vehicleNumber': _vehicleNumberController.text,
          'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Order Fuel',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Google Maps Widget
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(0xFFE91E63),
                  ),
                ),
                child: _selectedLocation == null
                    ? Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!, // Use user's current location
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _getUserCurrentLocation(); // Get user location when map is created
                  },
                  onTap: (LatLng location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  markers: _selectedLocation != null
                      ? {
                    Marker(
                      markerId: MarkerId("selected-location"),
                      position: _selectedLocation!,
                    ),
                  }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              const SizedBox(height: 20),

              // Fuel Type Dropdown
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedFuelType,
                  hint: const Text("Select Fuel Type"),
                  items: ['Petrol', 'Diesel', 'Premium']
                      .map((fuel) => DropdownMenuItem(
                    value: fuel,
                    child: Text(fuel),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFuelType = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Vehicle Number Plate TextField
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _vehicleNumberController,
                  decoration: const InputDecoration(
                    hintText: 'Vehicle Number Plate',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Spacer(),

              // Submit Button
              ElevatedButton(
                onPressed: _showOrderConfirmation,
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
                  'Place Order',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
