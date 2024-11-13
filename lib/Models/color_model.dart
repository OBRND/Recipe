import 'package:flutter/material.dart';

class ChildColorModel {
  static final List<Color> childColors = [
    Colors.green.shade400,
    Colors.redAccent.shade400,
    Colors.orange.shade600,
    Colors.blueAccent.shade400,
    Colors.tealAccent.shade400,
    Colors.purple.shade400,
    Colors.pink.shade400,
    Colors.yellow.shade600,
    Colors.brown.shade400,
    Colors.cyan.shade400,
  ];

  // Method to get color for a specific child index
  static Color colorOfChild(int index) {
    return childColors[index % childColors.length];
  }
}
