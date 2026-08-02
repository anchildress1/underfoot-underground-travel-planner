import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/models.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
    : baseUrl = baseUrl ?? ApiConstants.baseUrl,
      _client = client ?? http.Client();

  Future<SearchResponse> search(
    String chatInput, {
    String? userLocation,
    bool force = false,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.searchEndpoint}');
    final request = SearchRequest(
      chatInput: chatInput,
      userLocation: userLocation,
      force: force,
    );

    if (kDebugMode) {
      debugPrint('🔍 API Request: POST $uri');
      debugPrint('📦 Request body: ${jsonEncode(request.toJson())}');
    }

    try {
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConstants.timeout);

      if (kDebugMode) {
        debugPrint('📥 Response status: ${response.statusCode}');
        debugPrint(
          '📥 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
        );
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SearchResponse.fromJson(json);
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('❌ API Error: $e');
      rethrow;
    }
  }

  Future<bool> checkHealth() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.healthEndpoint}');

    if (kDebugMode) debugPrint('🏥 Health check: GET $uri');

    try {
      final response = await _client.get(uri).timeout(ApiConstants.timeout);
      if (kDebugMode) debugPrint('🏥 Health status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Health check failed: $e');
      return false;
    }
  }

  String _parseErrorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['message'] ?? json['error'] ?? 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
