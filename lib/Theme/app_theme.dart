import 'package:flutter/material.dart';

class AppThemes {
  // Define colors
  static const Color dominantColor = Color(0xFFFFFFFF); // White
  static const Color secondaryColor = Color(0xFFFAEFEB); // Silver
  static const Color accentColor = Color(0xDBF32607); // International Orange
  static const Color thunderColor = Color(0xFF251D1D); // Thunder
  static const Color flameGray = Color(0xFF6D6A6A); // Flame Gray
  static const Color siennaColor = Color(0xFF6E1903); // Sienna
  static const Color oldRedColor = Color(0xFF8D1419); // Old Red

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: dominantColor,
    scaffoldBackgroundColor: dominantColor,
    appBarTheme: AppBarTheme(
      color: dominantColor,
      surfaceTintColor: accentColor,
        titleTextStyle: TextStyle(color: thunderColor, fontWeight: FontWeight.bold, fontSize: 18)
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0)
      ),
    ),
    cardTheme: CardTheme(
      elevation: 5,
      color: dominantColor,
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
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    ),
    iconTheme: IconThemeData(color: thunderColor),
    tabBarTheme: TabBarTheme(
      indicatorColor: accentColor
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
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
      ),
      checkColor: WidgetStateProperty.all(dominantColor),
      overlayColor: WidgetStateProperty.all(accentColor),
    )
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
