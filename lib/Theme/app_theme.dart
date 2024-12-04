import 'package:flutter/material.dart';

class AppThemes {
  // Define colors
  static const Color dominantColor = Color(0xFFFFFFFF); // White
  static const Color secondaryColor = Color(0xFFABABAB); // Silver
  static const Color accentColor = Color(0xFFFF4500); // International Orange
  static const Color thunderColor = Color(0xFF251D1D); // Thunder
  static const Color flameGray = Color(0xFF6D6A6A); // Flame Gray
  static const Color siennaColor = Color(0xFF6E1903); // Sienna
  static const Color oldRedColor = Color(0xFF8D1419); // Old Red

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: dominantColor,
    scaffoldBackgroundColor: dominantColor,
    cardTheme: CardTheme(
      color: secondaryColor,
      shadowColor: thunderColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: thunderColor,
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: flameGray,
        fontSize: 16.0,
      ),
    ),
  );

  // Dark theme (if required, toggleable via settings)
  // static final ThemeData darkTheme = ThemeData(
  //   brightness: Brightness.dark,
  //   primaryColor: thunderColor,
  //   scaffoldBackgroundColor: thunderColor,
  //   accentColor: siennaColor,
  //   cardTheme: CardTheme(
  //     color: flameGray,
  //     shadowColor: oldRedColor,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12.0),
  //     ),
  //   ),
  //   elevatedButtonTheme: ElevatedButtonThemeData(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: siennaColor,
  //       foregroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8.0),
  //       ),
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  //     ),
  //   ),
  //   textTheme: TextTheme(
  //     headline1: TextStyle(
  //       color: dominantColor,
  //       fontSize: 24.0,
  //       fontWeight: FontWeight.bold,
  //     ),
  //     bodyText1: TextStyle(
  //       color: secondaryColor,
  //       fontSize: 16.0,
  //     ),
  //     button: TextStyle(
  //       color: Colors.white,
  //       fontSize: 14.0,
  //       fontWeight: FontWeight.w600,
  //     ),
  //   ),
  // );
}
