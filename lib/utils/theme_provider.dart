import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.white,
      cardColor: const Color(0xFF1A1A1A),
      dividerColor: const Color(0xFF2A2A2A),
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Color(0xFF8BC34A),
        surface: Color(0xFF1A1A1A),
        background: Colors.black,
      ),
    );
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      primaryColor: Colors.black,
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE0E0E0),
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
        secondary: Color(0xFF8BC34A),
        surface: Colors.white,
        background: Color(0xFFF5F5F5),
      ),
    );
  }
}