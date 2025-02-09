import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_delivery_app/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? email;
  String? phoneNumber;
  int _selectedIndex = 2; // Ensure "Account" is selected

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        email = user.email;
      });

      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          phoneNumber = userDoc['mobileNumber'] ?? 'Not provided';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Prevent unnecessary navigation
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) { // Navigate to Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${email ?? 'Loading...'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Phone: ${phoneNumber ?? 'Loading...'}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex, // Ensure "Account" icon is highlighted
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }
}
