import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static String id = "Notification Screen";

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  final List<RemoteMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    // ✅ استقبال الإشعارات أثناء تشغيل التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _messages.insert(0, message); // إضافة الإشعار في بداية القائمة
      });

      // ✅ عرض Snackbar كمثال
      if (message.notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${message.notification!.title ?? 'New Notification'}\n${message.notification!.body ?? ''}',
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  void shareNotification(String? content) {
    if (content != null) {
      Share.share(content);
    }
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
            child: _messages.isEmpty
                ? const Center(child: Text('No notifications yet.'))
                : ListView.separated(
                    itemCount: _messages.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.grey[400],
                      indent: size.width * .08,
                      endIndent: size.width * .08,
                    ),
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.3,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) =>
                                  shareNotification(message.notification?.body),
                              icon: Icons.share,
                              backgroundColor: Colors.grey[300]!,
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                setState(() {
                                  _messages.removeAt(index);
                                });
                              },
                              icon: Icons.delete,
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red[700]!,
                            ),
                          ],
                        ),
                        child: ListTile(
                          isThreeLine: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.08),
                          leading: const CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                AssetImage('assets/applogo.png'),
                          ),
                          title: Text(
                            message.notification?.title ?? 'No Title',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            message.notification?.body ??
                                'No message content',
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
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Account'),
          ],
        );
      },
    );
  }
}
