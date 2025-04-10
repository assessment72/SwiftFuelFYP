/// Author: Fahad Riaz
/// Description: This file defines the HomeScreen for the SwiftFuel app, which acts as the main dashboard for customers.
/// It displays current fuel prices, a brief overview of the fuel delivery service, and provides access to key features like fuel ordering.
/// The screen also includes logout functionality and a bottom navigation bar for seamless movement between major parts of the app.





import 'package:flutter/material.dart';
import 'package:fuel_delivery_app/screens/fuelordering_screen.dart';
import 'package:fuel_delivery_app/screens/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_delivery_app/screens/pastorders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  final List<Map<String, dynamic>> fuelPrices = [
    {'type': 'Petrol', 'price': 1.39, 'color': Colors.black},
    {'type': 'Diesel', 'price': 1.5, 'color': Colors.black},
    {'type': 'Premium', 'price': 2.12, 'color': Colors.black},
  ];

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildFuelPriceDisplay(),
                const SizedBox(height: 30),
                _buildFuelServiceInfo(),
                const SizedBox(height: 30),
                _buildOrderFuelButton(context),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Refueling Made Easy, Anytime, Anywhere.',
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          key: const Key('logoutButton'),
          icon: const Icon(Icons.logout, color: Colors.black),
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  Widget _buildFuelPriceDisplay() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fuelPrices.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final fuel = fuelPrices[index];
          return Container(
            width: 115,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.09),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: fuel['color'], width: 2),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fuel['type'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: fuel['color'],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '\£${fuel['price'].toStringAsFixed(2)} / L',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFuelServiceInfo() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDF9FB9), Color(0xFFF8D49D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '24/7 Fuel service, at petrol station rates.',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enjoy our contactless fuel delivery straight to your car with flexible scheduling.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: null,
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Color(0xFFE91E63)),
              foregroundColor: MaterialStatePropertyAll(Colors.white),
            ),
            child: Text('Discover SwiftFuel'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFuelButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        key: const Key('orderFuelButton'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FuelOrderingScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2F2F2),
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 30,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10,
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Text(
              'Order Fuel',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Color(0xFFE91E63),
              radius: 16,
              child: Icon(Icons.local_gas_station, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (context, selectedIndex, _) {
        return BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: selectedIndex,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: (index) {
            _selectedIndex.value = index;
            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PastOrdersScreen()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfileScreen()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Orders'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
          ],
        );
      },
    );
  }
}
