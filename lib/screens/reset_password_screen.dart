import 'dart:ui';
import 'package:flutter/material.dart';
import '../firebase_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Firebase service instance to handle password reset
  final FirebaseService _firebaseService = FirebaseService();
  // Controller for the email input field
  final TextEditingController _emailController = TextEditingController();
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Method to handle password reset
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      await _firebaseService.resetPassword(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the device orientation is portrait
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
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
            children: _buildFormContent(context).sublist(2), // Form field and button
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
      SizedBox(height: 30),
      ElevatedButton(
        onPressed: _resetPassword,
        child: Text('RESET PASSWORD'),
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
