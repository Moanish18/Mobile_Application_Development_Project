import 'package:flutter/material.dart';

/// [ThemeProvider] is a class that extends [ChangeNotifier] to manage theme and font settings.
/// It allows toggling between light and dark themes and changing the font family used in the app.
class ThemeProvider with ChangeNotifier {
  // Private variables to store the current theme mode and font family.
  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Roboto';

  /// Getter to retrieve the current theme mode.
  ThemeMode get currentTheme => _themeMode;

  /// Getter to check if the current theme is dark mode.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Getter to check if the current theme is light mode.
  bool get isLightMode => _themeMode == ThemeMode.light;

  /// Getter to retrieve the current font family.
  String get fontFamily => _fontFamily;

  /// Toggles between light and dark mode.
  /// Updates the theme mode and notifies listeners about the change.
  void toggleDarkMode() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners(); // Notify listeners to rebuild UI with new theme mode.
  }

  /// Sets the font family to the provided [fontFamily] value.
  /// Updates the font family and notifies listeners about the change.
  void setFontFamily(String fontFamily) {
    _fontFamily = fontFamily;
    notifyListeners(); // Notify listeners to rebuild UI with new font family.
  }

  /// Returns the light theme data with the current font family applied.
  ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light, // Set theme brightness to light.
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontFamily: _fontFamily),
        bodyMedium: TextStyle(fontFamily: _fontFamily),
        bodySmall: TextStyle(fontFamily: _fontFamily),
      ),
    );
  }

  /// Returns the dark theme data with the current font family applied.
  ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark, // Set theme brightness to dark.
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontFamily: _fontFamily),
        bodyMedium: TextStyle(fontFamily: _fontFamily),
        bodySmall: TextStyle(fontFamily: _fontFamily),
      ),
    );
  }
}
