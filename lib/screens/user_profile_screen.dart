import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/theme_provider.dart'; // Import the theme provider class
import '../firebase_service.dart'; // Import Firebase service class

class UserProfilePage extends StatefulWidget {
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _selectedFont = 'Roboto'; // Default font selection
  final FirebaseService _firebaseService = FirebaseService(); // Instance of FirebaseService

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Access the theme provider
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait; // Check orientation

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: isPortrait ? _buildPortraitLayout(context, themeProvider) : _buildLandscapeLayout(context, themeProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        child: Icon(Icons.logout),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Portrait layout
  Widget _buildPortraitLayout(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      children: _buildProfileContent(context, themeProvider),
    );
  }

  // Landscape layout
  Widget _buildLandscapeLayout(BuildContext context, ThemeProvider themeProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: _buildProfileContent(context, themeProvider).sublist(0, 4), // First column in landscape
          ),
        ),
        Expanded(
          child: Column(
            children: _buildProfileContent(context, themeProvider).sublist(4), // Second column in landscape
          ),
        ),
      ],
    );
  }

  // Build profile content
  List<Widget> _buildProfileContent(BuildContext context, ThemeProvider themeProvider) {
    return [
      Text('Profile Picture:', style: TextStyle(fontSize: 19.5, fontWeight: FontWeight.bold)),
      CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage('images/profile_picture.png'),
      ),
      SizedBox(height: 10),
      Text('Username: Moanish18', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      ProfileItem(label: 'Email', value: 'ish****@gmail.com'), // Display email
      ProfileItem(label: 'Age', value: '18'), // Display age
      ProfileItem(label: 'Password', value: '********'), // Display password (masked)
      SizedBox(height: 20),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/update-password'); // Navigate to update password screen
        },
        child: Text('Update Password'),
      ),
      SizedBox(height: 20),
      Text('Select Font', style: TextStyle(fontSize: 16)),
      DropdownButton<String>(
        value: _selectedFont, // Selected font value
        items: <String>['Lobster', 'OpenSans', 'Pacifico', 'Roboto'] // Font options
            .map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedFont = newValue!; // Update selected font
          });
          themeProvider.setFontFamily(newValue!); // Update font in theme provider
        },
      ),
      SizedBox(height: 20),
      Text('Dark Mode', style: TextStyle(fontSize: 16)),
      Switch(
        value: themeProvider.isDarkMode, // Dark mode value from theme provider
        onChanged: (value) {
          themeProvider.toggleDarkMode(); // Toggle dark mode
        },
      ),
    ];
  }

  // Logout function
  void _logout() async {
    await _firebaseService.logoutUser(); // Call the logout method from FirebaseService
    Navigator.pushNamedAndRemoveUntil(context, '/login-register', (route) => false); // Navigate to login-register page
  }
}

// Profile item widget
class ProfileItem extends StatelessWidget {
  final String label; // Label for the profile item
  final String value; // Value for the profile item

  ProfileItem({required this.label, required this.value}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(fontSize: 16)), // Label text
          Text(value, style: TextStyle(fontSize: 16)), // Value text
        ],
      ),
    );
  }
}
