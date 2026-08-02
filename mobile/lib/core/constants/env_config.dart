import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class EnvConfig {
  static String get apiBase {
    const definedBase = String.fromEnvironment('API_BASE');
    if (definedBase.isNotEmpty) return definedBase;

    // Default fallbacks based on platform
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    
    return 'http://localhost:8000';
  }

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  static const bool enableDebugPanel = bool.fromEnvironment(
    'ENABLE_DEBUG',
    defaultValue: true,
  );
}
