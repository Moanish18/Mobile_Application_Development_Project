import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_service.dart';

// LoginPage provides a user interface for user login
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Method to handle user login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      User? user = await _firebaseService.loginUser(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
      }
    }
  }

  // Method to handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    User? user = await _firebaseService.signInWithGoogle();
    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the device is in portrait mode
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'), // App bar title
        centerTitle: true, // Center the title
        backgroundColor: Colors.green, // App bar background color
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'images/background_image.png',
            fit: BoxFit.cover,
          ),
          // Background blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Colors.black.withOpacity(0),
            ),
          ),
          // Overlay with semi-transparent black color
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Centered content with scrollable form
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: isPortrait ? _buildPortraitLayout(context) : _buildLandscapeLayout(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the layout for portrait orientation
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildContent(context),
    );
  }

  // Build the layout for landscape orientation
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildContent(context).sublist(0, 2), // Logo images
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildContent(context).sublist(2), // Text and form
          ),
        ),
      ],
    );
  }

  // Build the content for the page
  List<Widget> _buildContent(BuildContext context) {
    return [
      Image.asset('images/greenhub_logo.png', height: 100), // Display GreenHub logo
      Image.asset('images/logo.png', height: 150), // Display another logo
      SizedBox(height: 30),
      // Email input field
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      // Password input field
      TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        obscureText: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
      ),
      SizedBox(height: 30),
      // Login button
      ElevatedButton(
        onPressed: _login,
        child: Text('LOGIN'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          textStyle: TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 20),
      // Sign Up button
      ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: Text('SIGN UP'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 48, 142, 1),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          textStyle: TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 20),
      // Google Sign-In button
      ElevatedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: Icon(Icons.account_circle),
        label: Text('SIGN IN WITH GOOGLE'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          textStyle: TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 20),
      // Forgot password button
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/reset-password');
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ];
  }
}
