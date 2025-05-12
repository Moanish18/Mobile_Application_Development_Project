import 'package:flutter/material.dart';

// LoginRegisterPage provides options to navigate to login or register pages
class LoginRegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Determine if the device is in portrait mode
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login/Register Option Page'), // App bar title
        centerTitle: true, // Center the title
        backgroundColor: Colors.green, // App bar background color
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'images/background_image.png',
            fit: BoxFit.cover,
          ),
          // Overlay with semi-transparent black color
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Centered content
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: isPortrait ? _buildPortraitLayout(context) : _buildLandscapeLayout(context),
            ),
          ),
        ],
      ),
    );
  }

  // Build the layout for portrait orientation
  Widget _buildPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildContent(context),
      ),
    );
  }

  // Build the layout for landscape orientation
  Widget _buildLandscapeLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
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
              children: _buildContent(context).sublist(2), // Text and buttons
            ),
          ),
        ],
      ),
    );
  }

  // Build the content for the page
  List<Widget> _buildContent(BuildContext context) {
    return [
      Image.asset('images/greenhub_logo.png', height: 150), // Display GreenHub logo
      Image.asset('images/logo.png', height: 200), // Display another logo
      SizedBox(height: 30),
      Text(
        'Nurturing Nature, Empowering Communities', // Slogan
        style: TextStyle(
          fontSize: 20,
          color: const Color.fromRGBO(0, 255, 88, 1),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 30),
      ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login'); // Navigate to login page
        },
        child: Text('LOGIN'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          textStyle: TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register'); // Navigate to register page
        },
        child: Text('REGISTER'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          textStyle: TextStyle(fontSize: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ];
  }
}
