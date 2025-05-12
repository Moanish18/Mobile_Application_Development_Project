import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Firebase service instance to handle authentication
  final FirebaseService _firebaseService = FirebaseService();
  // Controllers for form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Method to handle user registration
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      User? user = await _firebaseService.registerUser(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
        int.parse(_ageController.text),
      );
      if (user != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the device orientation is portrait
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'images/background_image.png',
            fit: BoxFit.cover,
          ),
          // Background blur
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

  // Build the portrait layout
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildFormContent(context),
    );
  }

  // Build the landscape layout
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildFormContent(context).sublist(0, 2), // Logo images
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildFormContent(context).sublist(2), // Form fields
          ),
        ),
      ],
    );
  }

  // Build the form content
  List<Widget> _buildFormContent(BuildContext context) {
    return [
      Image.asset('images/greenhub_logo.png', height: 100),
      Image.asset('images/logo.png', height: 150),
      SizedBox(height: 30),
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
      SizedBox(height: 20),
      TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your username';
          }
          return null;
        },
      ),
      SizedBox(height: 20),
      TextFormField(
        controller: _ageController,
        decoration: InputDecoration(
          labelText: 'Age',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your age';
          }
          return null;
        },
      ),
      SizedBox(height: 30),
      ElevatedButton(
        onPressed: _register,
        child: Text('REGISTER'),
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
    ];
  }
}
