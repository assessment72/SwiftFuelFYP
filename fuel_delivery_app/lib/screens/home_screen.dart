/// Author: Fahad Riaz
/// Description: This file defines the HomeScreen for the SwiftFuel app, which acts as the main dashboard for customers.
/// It displays current fuel prices, a brief overview of the fuel delivery service, and provides access to key features like fuel ordering.
/// The screen also includes logout functionality and a bottom navigation bar for seamless movement between major parts of the app.





import 'package:flutter/material.dart';
import 'package:fuel_delivery_app/screens/fuelordering_screen.dart';
import 'package:fuel_delivery_app/screens/user_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_delivery_app/screens/pastorders_screen.dart';
import 'package:fuel_delivery_app/generated/app_localizations.dart';

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
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(localizations),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildFuelPriceDisplay(localizations),
                const SizedBox(height: 30),
                _buildFuelServiceInfo(localizations),
                const SizedBox(height: 30),
                _buildOrderFuelButton(context, localizations),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(localizations),
    );
  }

  AppBar _buildAppBar(AppLocalizations localizations) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      title: Text(
        localizations.refuelingMadeEasy,
        style: TextStyle(
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
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
          icon: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.signedOutSuccessfully)),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.errorSigningOut}: $e')),
      );
    }
  }

  Widget _buildFuelPriceDisplay(AppLocalizations localizations) {
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
              color: Theme.of(context).cardColor.withOpacity(0.09),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: fuel['color'], width: 2),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fuel['type'] == 'Petrol' ? localizations.petrol :
                  fuel['type'] == 'Diesel' ? localizations.diesel :
                  localizations.premium,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: fuel['color'],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '£${fuel['price'].toStringAsFixed(2)} / L',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFuelServiceInfo(AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.fuelService247,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.contactlessDelivery,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: null,
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor),
              foregroundColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.onPrimary),
            ),
            child: Text(localizations.discoverSwiftFuel),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFuelButton(BuildContext context, AppLocalizations localizations) {
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
          backgroundColor: Theme.of(context).cardColor,
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
          children: [
            Text(
              localizations.orderFuel,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 16,
              child: Icon(Icons.local_gas_station, size: 20, color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(AppLocalizations localizations) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedIndex,
      builder: (context, selectedIndex, _) {
        return BottomNavigationBar(
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
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
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home), label: localizations.home),
            BottomNavigationBarItem(icon: const Icon(Icons.shopping_cart), label: localizations.orders),
            BottomNavigationBarItem(icon: const Icon(Icons.account_circle), label: localizations.account),
          ],
        );
      },
    );
  }
}


