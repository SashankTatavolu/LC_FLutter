// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lc_frontend/views/home_page.dart';
import '../services/auth_service.dart';
import '../models/login_request.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double boxWidth = 500.0;
  static const double imageHeight = 200.0;
  static const double spaceHeight = 20.0;
  static const double boxShadowOpacity = 0.1;
  static const double boxShadowSpreadRadius = 5.0;
  static const double boxShadowBlurRadius = 7.0;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: Stack(
        children: <Widget>[
          _buildLoginBox(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildLoginBox(BuildContext context) {
    return Center(
      child: Container(
        width: boxWidth,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(boxShadowOpacity),
              spreadRadius: boxShadowSpreadRadius,
              blurRadius: boxShadowBlurRadius,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset('assets/images/logo.png', height: imageHeight),
            const SizedBox(height: spaceHeight),
            _buildTextField('Username', false, _usernameController),
            const SizedBox(height: spaceHeight),
            _buildTextField('Password', true, _passwordController),
            const SizedBox(height: spaceHeight),
            ElevatedButton(
              onPressed: _loginPressed,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Powered by',
              style:
                  TextStyle(color: Colors.black, fontStyle: FontStyle.italic)),
          const SizedBox(height: spaceHeight),
          Row(
            children: <Widget>[
              Image.asset('assets/images/institution1.png', height: 80),
              const SizedBox(width: 5),
              Image.asset('assets/images/institution2.png', height: 80),
            ],
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _loginPressed() async {
    var username = _usernameController.text;
    var password = _passwordController.text;

    print('Username: $username'); // Print username
    print('Password: $password'); // Print password
    var loginRequest = LoginRequest(
      username: _usernameController.text,
      password: _passwordController.text,
    );
    var response = await _authService.authenticateUser(loginRequest);
    if (response != null) {
      // Store username in secure storage
      await _storage.write(key: 'username', value: _usernameController.text);

      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Show login error
      print('Login Failed');
      _showErrorDialog('Incorrect username or password. Please try again.');
    }
  }
}
