import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_delivery_app/services/auth_service.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({Key? key}) : super(key: key);

  @override
  _DeliveryDashboardScreenState createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _driverId = user.uid; // Get the logged-in delivery partner ID
      });
    }
  }

  Future<void> _assignOrder(String orderId) async {
    if (_driverId == null) return;

    // Check if order is already assigned
    DocumentSnapshot orderSnapshot = await _firestore.collection('orders').doc(orderId).get();
    if (orderSnapshot.exists && orderSnapshot['assignedDriverId'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This order has already been assigned to another driver.')),
      );
      return;
    }

    // Assign the order to the current driver
    await _firestore.collection('orders').doc(orderId).update({
      'assignedDriverId': _driverId,
      'status': 'Assigned', // Updating status in Firestore
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order successfully assigned to you!')),
    );
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .where('status', isEqualTo: 'Pending') // Ensure order is pending
            .where('assignedDriverId', isEqualTo: null) // Ensure it's unassigned
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

          // Debugging: Print fetched orders
          print("Orders received: ${orders.length}");
          for (var order in orders) {
            print("Order ID: ${order.id}, Assigned Driver: ${order['assignedDriverId']}");
          }

          return ListView.builder(
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
          );
        },
      ),
    );
  }
}
