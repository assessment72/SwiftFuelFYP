/// Author: Fahad Riaz
/// Description: This screen provides a user registration interface for the SwiftFuel app.
/// It allows new users to register with email, password, and mobile number. The registration
/// data is stored in Firebase Authentication and Firestore. The screen also includes
/// input validation, password visibility toggle, redirection to login screen, and responsive UI.

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); // ✅ تم إضافة const constructor

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _isPasswordVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Image.asset('assets/logo.png', height: 200),
                    const SizedBox(height: 30),

                    // Email Field
                    _buildTextField(
                      _emailController,
                      'Email',
                      Icons.email,
                      false,
                      key: const Key('regEmailField'),
                    ),
                    const SizedBox(height: 15),

                    // Password Field
                    ValueListenableBuilder(
                      valueListenable: _isPasswordVisible,
                      builder: (context, value, _) {
                        return _buildTextField(
                          _passwordController,
                          'Password',
                          Icons.lock,
                          !value,
                          suffixIcon: IconButton(
                            icon: Icon(value ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => _isPasswordVisible.value = !_isPasswordVisible.value,
                          ),
                          key: const Key('regPasswordField'),
                        );
                      },
                    ),
                    const SizedBox(height: 15),

                    // Mobile Field
                    _buildTextField(
                      _mobileController,
                      'Mobile Number',
                      Icons.phone,
                      false,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixText: '+44 ',
                      key: const Key('regMobileField'),
                    ),
                    const SizedBox(height: 25),

                    // Register Button & Redirect
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            child: const Text(
                              'Already have an account? Login here',
                              style: TextStyle(fontSize: 9, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: screenWidth * 0.4,
                          height: 50,
                          child: FilledButton(
                            key: const Key('registerButton'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _isLoading ? null : _handleRegister,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Register', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String mobileNumber = _mobileController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty && mobileNumber.isNotEmpty) {
      User? user = await _authService.register(email, password);

      if (user != null) {
        final String fullMobileNumber = '+44 $mobileNumber';

        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'mobileNumber': fullMobileNumber,
          'role': 'customer',
          'createdAt': Timestamp.now(),
        });

        Navigator.pushNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed. Try again.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields.')));
    }

    setState(() => _isLoading = false);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool obscureText, {
    Widget? suffixIcon,
    Key? key,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String prefixText = '',
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(50.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                prefixText: prefixText,
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
