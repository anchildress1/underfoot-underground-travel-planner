import 'package:flutter/material.dart';

abstract final class AppColors {
  // Design System: Electric Violet & Magenta (from image)
  
  // Primary Accents
  static const Color electricViolet = Color(0xFF7953FC);
  static const Color magenta = Color(0xFF3E5CFF); // Label says Magenta, looks Blue-ish/Purple
  static const Color cyan = Color(0xFF00E5FF);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [electricViolet, magenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [magenta, cyan],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Backgrounds
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color darkBackground = Color(0xFF080A12); // Deep Navy/Black
  
  // Surfaces
  static const Color lightSurface = Colors.white;
  static const Color darkSurface = Color(0xFF151925);
  
  // Text
  static const Color lightText = Color(0xFF1A1F2E);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8F9BB3);

  // Functional
  static const Color success = Color(0xFF00E096);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF3D71);
  static const Color info = Color(0xFF0095FF);

  // Chat Bubbles
  static const Color userBubbleLight = electricViolet;
  static const Color userBubbleDark = electricViolet;
  static const Color assistantBubbleLight = Colors.white;
  static const Color assistantBubbleDark = Color(0xFF1F2636);

  // Map
  static const Color mapMarkerPrimary = magenta;
  static const Color mapMarkerSecondary = cyan;
  
  // Legacy Mapping (for compatibility during refactor)
  static const Color primary = electricViolet;
  static const Color background = darkBackground; // Default to dark for now
  static const Color surface = darkSurface;
  static const Color surfaceVariant = Color(0xFF222939);
  static const Color textPrimary = darkText;
  static const Color accent = cyan;
  
  // Steampunk fallbacks (mapped to new clean colors)
  static const Color steampunkBronze = magenta; 
  static const Color steampunkBrass = warning;
  static const Color steampunkCopper = electricViolet;
  static const Color steampunkRust = error;
  static const Color steampunkDarkMetal = darkSurface;
  
  // Neon fallbacks
  static const Color neonGreen = success;
  static const Color neonCyan = cyan;
  static const Color neonPink = magenta;
  static const Color neonPurple = electricViolet;
  
  static const Color electricVioletLight = Color(0xFFB794F4);
  static const Color magentaDark = Color(0xFF22558A);
  static const Color lightBackgroundAlt = Color(0xFFE4E9F2);
  static const Color lightSurfaceVariant = Color(0xFFF7F9FC);
  static const Color lightTextSecondary = Color(0xFF8F9BB3);
  static const Color darkBackgroundGradientStart = darkBackground;
  static const Color darkBackgroundGradientMid = Color(0xFF101426);
  static const Color darkBackgroundGradientEnd = darkSurface;
  static const Color darkSurfaceVariant = surfaceVariant;
  static const Color darkTextSecondary = textSecondary;
  static const Color cta = magenta;
  static const Color chatUserBubble = electricViolet;
  static const Color chatAssistantBubbleLight = assistantBubbleLight;
  static const Color chatAssistantBubbleDark = assistantBubbleDark;
}
