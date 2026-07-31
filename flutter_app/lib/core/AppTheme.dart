import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF101419);
  static const Color surface = Color(0xFF151A21);
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color userBubble = Color(0xFF2C3E50);
  static const Color skaldBubble = Color(0xFF1E272E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE0E0E0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: skaldBubble,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: userBubble,
      ),
      fontFamily: 'Georgia', 
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 2,
        shadowColor: Colors.black,
        centerTitle: true,
        titleTextStyle: TextStyle(
          letterSpacing: 2.0,
          fontWeight: FontWeight.bold,
          color: primaryGold,
          fontSize: 20,
        ),
      ),
    );
  }
}