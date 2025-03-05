import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 200,
            ),

            // Email Input Field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(50.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.email, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Password Input Field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(50.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.key, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: InputBorder.none,
                      ),
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ),

            // Mobile Number Input Field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(50.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(
                        prefixText: '+44 ',
                        labelText: 'Mobile Number',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Already have an account? Login here',
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  ),

                  // Register Button
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      minimumSize: Size(150, 50),
                    ),
                    onPressed: () async {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
                      String mobileNumber = _mobileController.text.trim();

                      if (email.isNotEmpty && password.isNotEmpty && mobileNumber.isNotEmpty) {
                        User? user = await _authService.register(email, password);

                        if (user != null) {
                          String fullMobileNumber = '+44 ' + mobileNumber;

                          // Store User Data & Role in Firestore
                          await _firestore.collection('users').doc(user.uid).set({
                            'email': email,
                            'mobileNumber': fullMobileNumber,
                            'role': 'customer',
                            'createdAt': Timestamp.now(),
                          });

                          Navigator.pushNamed(context, '/login');
                          print('Registration successful');
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Registration successful')));
                        } else {
                          print('Registration failed');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registration failed. Try again.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill all fields.')),
                        );
                      }
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
