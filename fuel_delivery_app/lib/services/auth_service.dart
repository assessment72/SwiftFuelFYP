import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registration with email and password
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user;

    } catch (e) {
      print ('Error:  $e');
      return null;
    }
  }

  // Login with email and password
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return user;
    } catch (e) {
      print ('Error:  $e');
      return null;
    }
  }

  // Logout
  Future<void> logOut() async {
    await _auth.signOut();
  }
}


