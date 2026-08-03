import 'env_config.dart';

abstract final class ApiConstants {
  static String get baseUrl => EnvConfig.apiBase;
  static const String searchEndpoint = '/api/underfoot/search';
  static const String healthEndpoint = '/api/underfoot/health';
  static const Duration timeout = Duration(seconds: 30);
}
