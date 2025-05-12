import 'dart:ui';
import 'package:flutter/material.dart';
import '../firebase_service.dart'; // Firebase service file

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final FirebaseService _firebaseService = FirebaseService(); // Instance of FirebaseService
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // GlobalKey for the form

  // Function to handle password update
  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      // Validate form fields
      // You can add old password verification logic here if needed

      // Call FirebaseService to update password
      await _firebaseService.updatePassword(_newPasswordController.text);

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Password'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur effect
          Image.asset(
            'images/background_image.png',
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Colors.black.withOpacity(0), // Transparent background
            ),
          ),
          // Overlay to darken the background
          Container(
            color: Colors.black.withOpacity(0.5), // Semi-transparent black overlay
          ),
          // Centered content within SingleChildScrollView
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Form key for validation
                child: isPortrait ? _buildPortraitLayout(context) : _buildLandscapeLayout(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build UI layout for portrait orientation
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildFormContent(context), // Build form content
    );
  }

  // Build UI layout for landscape orientation
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildFormContent(context).sublist(0, 2), // Logo images in the first column
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildFormContent(context).sublist(2), // Form fields and button in the second column
          ),
        ),
      ],
    );
  }

  // Build form content widgets
  List<Widget> _buildFormContent(BuildContext context) {
    return [
      Image.asset('images/greenhub_logo.png', height: 100), // GreenHub logo image
      Image.asset('images/logo.png', height: 150), // Main logo image
      SizedBox(height: 30), // Spacer
      TextFormField(
        controller: _oldPasswordController,
        decoration: InputDecoration(
          labelText: 'Old Password',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        obscureText: true, // Hide text input for old password
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your old password';
          }
          return null;
        },
      ),
      SizedBox(height: 20), // Spacer
      TextFormField(
        controller: _newPasswordController,
        decoration: InputDecoration(
          labelText: 'New Password',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        obscureText: true, // Hide text input for new password
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your new password';
          }
          return null;
        },
      ),
      SizedBox(height: 30), // Spacer
      ElevatedButton(
        onPressed: _updatePassword, // Call _updatePassword function when pressed
        child: Text('UPDATE PASSWORD'), // Button text
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // Text color
          backgroundColor: Colors.black, // Button background color
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Button padding
          textStyle: TextStyle(fontSize: 20), // Button text style
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Button border radius
          ),
        ),
      ),
    ];
  }
}
