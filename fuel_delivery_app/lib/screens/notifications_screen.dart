/// Author: Fahad Riaz
/// Description: This file defines the NotificationsScreen for the SwiftFuel app.
/// It displays a list of notifications with swipe actions for sharing and deleting.
/// The screen includes a bottom navigation bar for seamless movement between major parts of the app.

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static String id = "Notification Screen";

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  void shareNotification() {
    Share.share('Notification shared from SwiftFuel app.');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notifications',
                labelText: 'Notifications',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[400],
                indent: size.width * .08,
                endIndent: size.width * .08,
              ),
              itemBuilder: (context, index) {
                return Slidable(
                  endActionPane: ActionPane(
                    extentRatio: 0.3,
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => shareNotification(),
                        icon: Icons.share,
                        backgroundColor: Colors.grey[300]!,
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification deleted')),
                          );
                        },
                        icon: Icons.delete,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red[700]!,
                      ),
                    ],
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/applogo.png'),
                    ),
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Team',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '2h Ago',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Please share the project update before Friday. The next meeting agenda will be based on it.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
            if (index == 0) {
              Navigator.pushNamed(context, '/home');
            } else if (index == 1) {
              Navigator.pushNamed(context, '/orders');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/account');
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
