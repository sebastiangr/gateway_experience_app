import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBlue = Color(0xFF0A192F); // Richer dark blue
  static const Color slateGray = Color(0xFF233554); // Slightly lighter than darkBlue for depth
  static const Color lightGray = Color(0xFFA8B2D1); // For text and subtle elements
  static const Color darkGray = Color(0xFF8892B0);  // For secondary text or icons
  static const Color mintGreen = Color(0xFF64FFDA); // Accent color
  static const Color white = Color(0xFFCCD6F6);     // Off-white for primary text

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [darkBlue, slateGray],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient playerGradient = LinearGradient(
    colors: [slateGray, darkBlue], // Reversed or slightly different
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}