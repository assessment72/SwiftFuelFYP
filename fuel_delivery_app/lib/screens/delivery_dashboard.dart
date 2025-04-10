/// Author: Fahad Riaz
/// Description: This file implements the Delivery Dashboard Screen for SwiftFuel, designed specifically for delivery drivers.
/// It displays available unassigned fuel orders as well as orders assigned to the current driver. Drivers can accept orders,
/// track and share their live location, and mark orders as completed. Firebase Firestore is used for real-time updates,
/// while the Location package tracks the driver’s location.




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_delivery_app/services/auth_service.dart';
import 'package:location/location.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({Key? key}) : super(key: key);

  @override
  _DeliveryDashboardScreenState createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _driverId;
  Location _location = Location();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _driverId = user.uid;
      });
    }
  }

  Future<void> _assignOrder(String orderId) async {
    if (_driverId == null) return;

    DocumentSnapshot orderSnapshot = await _firestore.collection('orders').doc(orderId).get();
    if (orderSnapshot.exists && orderSnapshot['assignedDriverId'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This order has already been assigned to another driver.')),
      );
      return;
    }

    await _firestore.collection('orders').doc(orderId).update({
      'assignedDriverId': _driverId,
      'status': 'Assigned',
    });

    _startLocationUpdates(orderId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order successfully assigned to you!')),
    );
  }

  Future<void> _markOrderAsDelivered(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Completed',
      'driverLocation': null,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order marked as Delivered!')),
    );
  }

  void _startLocationUpdates(String orderId) {
    _location.onLocationChanged.listen((LocationData currentLocation) async {
      if (_driverId == null) return;

      await _firestore.collection('orders').doc(orderId).update({
        'driverLocation': GeoPoint(currentLocation.latitude!, currentLocation.longitude!)
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Delivery Partner Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await AuthService().logOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .where('status', isEqualTo: 'Pending')
                  .where('assignedDriverId', isEqualTo: null)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No available orders for delivery at the moment.',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                }

                var orders = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Available Orders",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          var order = orders[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                "Fuel Type: ${order['fuelType']}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Vehicle: ${order['vehicleNumber']}\nLocation: ${order['location'].latitude}, ${order['location'].longitude}",
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _assignOrder(order.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                ),
                                child: const Text("Accept Order"),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .where('assignedDriverId', isEqualTo: _driverId)
                  .where('status', isEqualTo: 'Assigned')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No assigned orders at the moment.',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  );
                }

                var orders = snapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "My Assigned Orders",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          var order = orders[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                "Fuel Type: ${order['fuelType']}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Vehicle: ${order['vehicleNumber']}\nLocation: ${order['location'].latitude}, ${order['location'].longitude}",
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _markOrderAsDelivered(order.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                ),
                                child: const Text("Mark as Delivered"),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
