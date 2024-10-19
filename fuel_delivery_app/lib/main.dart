import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and catch any errors
  try {
    await Firebase.initializeApp();
    runApp(MyApp(firebaseInitialized: true));
  } catch (e) {
    runApp(MyApp(firebaseInitialized: false));
    print("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({Key? key, required this.firebaseInitialized}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Setup Test',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Setup Test'),
        ),
        body: Center(
          child: firebaseInitialized
              ? Text(
            'Firebase initialized successfully!',
            style: TextStyle(fontSize: 20, color: Colors.green),
          )
              : Text(
            'Firebase initialization failed!',
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
