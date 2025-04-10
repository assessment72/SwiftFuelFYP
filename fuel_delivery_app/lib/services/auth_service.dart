/// Author: Fahad Riaz
/// Description: This service handles all Firebase Authentication-related functionality
/// for the SwiftFuel app. It supports registration of new users (customers only),
/// login of existing users, and logout. It also stores and retrieves user data from
/// the Firebase Firestore database, including role-based access information.



import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registration with email and password (Only Customers)
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Store user data in Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': 'customer', // Default role is "customer"
        });
      }
      return user;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>?> logIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Logout
  Future<void> logOut() async {
    await _auth.signOut();
  }
}
