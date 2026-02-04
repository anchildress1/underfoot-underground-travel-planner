import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:underfoot_mobile/data/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('search returns SearchResponse on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/underfoot/search');
        expect(request.method, 'POST');

        final body = jsonDecode(request.body);
        expect(body['chat_input'], 'test query');

        return http.Response(
          jsonEncode({
            'response': 'Found some places',
            'places': [
              {'name': 'Test Place', 'latitude': 37.0, 'longitude': -122.0},
            ],
            'user_intent': 'find places',
            'user_location': 'San Francisco',
          }),
          200,
        );
      });

      final service = ApiService(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      final response = await service.search('test query');

      expect(response.response, 'Found some places');
      expect(response.places.length, 1);
      expect(response.places.first.name, 'Test Place');
      expect(response.userIntent, 'find places');
    });

    test('search throws ApiException on error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Server error'}), 500);
      });

      final service = ApiService(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      expect(
        () => service.search('test query'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message', 'Server error'),
        ),
      );
    });

    test('search passes force parameter correctly', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        expect(body['force'], true);

        return http.Response(jsonEncode({'response': 'OK', 'places': []}), 200);
      });

      final service = ApiService(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      await service.search('test', force: true);
    });

    test('checkHealth returns true on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/underfoot/health');
        return http.Response('{"status": "ok"}', 200);
      });

      final service = ApiService(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      final result = await service.checkHealth();
      expect(result, true);
    });

    test('checkHealth returns false on error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = ApiService(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      final result = await service.checkHealth();
      expect(result, false);
    });

    test('ApiException toString formats correctly', () {
      const exception = ApiException(statusCode: 404, message: 'Not found');
      expect(exception.toString(), 'ApiException(404): Not found');
    });

    test('parses error message from response body', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'error': 'Custom error'}), 400);
      });

      final service = ApiService(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      expect(
        () => service.search('test'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Custom error',
          ),
        ),
      );
    });

    test('handles malformed error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('not json', 500);
      });

      final service = ApiService(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      expect(
        () => service.search('test'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Request failed',
          ),
        ),
      );
    });
  });
}
