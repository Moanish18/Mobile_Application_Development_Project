import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Firebase configuration options
import 'firebase_service.dart'; // Custom Firebase service class
import 'widgets/theme_provider.dart'; // Theme provider for managing app themes
import 'screens/add_post_screen.dart'; // Screen for adding a new post
import 'screens/main_screen.dart'; // Main screen with navigation
import 'screens/user_profile_screen.dart'; // User profile screen
import 'screens/user_posts_screen.dart'; // Screen for displaying user posts
import 'screens/update_post_screen.dart'; // Screen for updating a post
import 'screens/login_register_screen.dart'; // Screen for login/register options
import 'screens/login_screen.dart'; // Login screen
import 'screens/register_screen.dart'; // Register screen
import 'screens/update_password_screen.dart'; // Screen for updating password
import 'screens/reset_password_screen.dart'; // Screen for resetting password
import 'screens/search_screen.dart'; // Search screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before running the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize Firebase with platform-specific options
  );
  GetIt.instance.registerLazySingleton(() => FirebaseService()); // Register FirebaseService as a singleton using GetIt
  runApp(GreenHubApp()); // Run the GreenHubApp
}

class GreenHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Provide ThemeProvider to manage theme changes
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Green Hub', // Title of the application
            themeMode: themeProvider.currentTheme, // Set theme mode (light/dark) based on the provider
            theme: themeProvider.getLightTheme(), // Define the light theme
            darkTheme: themeProvider.getDarkTheme(), // Define the dark theme
            initialRoute: '/login-register', // Initial route of the application
            routes: {
              '/': (context) => MainScreen(), // Route for main screen
              '/login-register': (context) => LoginRegisterPage(), // Route for login/register screen
              '/login': (context) => LoginPage(), // Route for login screen
              '/register': (context) => RegisterPage(), // Route for register screen
              '/reset-password': (context) => ResetPasswordPage(), // Route for reset password screen
              '/update-password': (context) => UpdatePasswordPage(), // Route for update password screen
              '/user-profile': (context) => UserProfilePage(), // Route for user profile screen
              '/user-posts': (context) => UserPostsPage(), // Route for user posts screen
              '/new-post': (context) => NewPostScreen(), // Route for adding a new post
              '/search': (context) => SearchPage(), // Route for search screen
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/update-post') {
                final postId = settings.arguments as String; // Retrieve postId from route arguments
                return MaterialPageRoute(
                  builder: (context) => UpdatePostPage(postId: postId), // Route for updating a post
                );
              } else {
                return null; // Return null if route is not recognized
              }
            },
          );
        },
      ),
    );
  }
}
