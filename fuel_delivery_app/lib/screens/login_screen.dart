/// Author: Fahad Riaz
/// Description: This file defines the login screen for SwiftFuel, allowing users to authenticate using Firebase.
/// Based on the user\'s role (customer or driver), the app navigates them to their respective dashboards.
/// It includes Firebase Auth integration, password visibility toggle, loading state, and error handling via snackbars.





import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_delivery_app/screens/home_screen.dart';
import 'package:fuel_delivery_app/screens/delivery_dashboard.dart';
import 'package:fuel_delivery_app/generated/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final ValueNotifier<bool> _isPasswordVisible = ValueNotifier<bool>(false);
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isPasswordVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final AppLocalizations localizations = AppLocalizations.of(context)!;

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
                    Image.asset(
                      'assets/logo.png',
                      height: 200,
                    ),
                    const SizedBox(height: 30),

                    // Email Field
                    _buildTextField(
                      _emailController,
                      localizations.email,
                      Icons.email,
                      false,
                      key: const Key('emailField'),
                    ),
                    const SizedBox(height: 15),

                    // Password Field with Visibility Toggle
                    ValueListenableBuilder(
                      valueListenable: _isPasswordVisible,
                      builder: (context, value, child) {
                        return _buildTextField(
                          _passwordController,
                          localizations.password,
                          Icons.lock,
                          !value,
                          suffixIcon: IconButton(
                            icon: Icon(value ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              _isPasswordVisible.value = !value;
                            },
                          ),
                          key: const Key('passwordField'),
                        );
                      },
                    ),
                    const SizedBox(height: 25),

                    // Register & Login Row
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              localizations.dontHaveAccount,
                              style: TextStyle(fontSize: 10, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: screenWidth * 0.4,
                          height: 50,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                                : Text(localizations.login, style: TextStyle(fontSize: 18)),
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

  /// Handles the login process
  void _handleLogin() async {
    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        var userData = await _authService.logIn(email, password);
        if (userData != null) {
          if (userData["role"] == "customer") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          } else if (userData["role"] == "driver") {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const DeliveryDashboardScreen()));
          }
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == "user-not-found") {
          message = localizations.userNotFound;
        } else if (e.code == "wrong-password") {
          message = localizations.wrongPassword;
        } else {
          message = localizations.loginFailed;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.loginFailed)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.pleaseFillAllFields)),
      );
    }

    setState(() => _isLoading = false);
  }

  /// Builds a custom text field widget
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      bool obscureText, {
        Widget? suffixIcon,
        Key? key,
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
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


