import 'package:flutter_test/flutter_test.dart';
import 'package:underfoot_mobile/data/models/models.dart';

void main() {
  group('Place', () {
    test('fromJson creates Place correctly', () {
      final json = {
        'id': '123',
        'name': 'Golden Gate Bridge',
        'description': 'Famous bridge in San Francisco',
        'address': 'Golden Gate Bridge, San Francisco, CA',
        'latitude': 37.8199,
        'longitude': -122.4783,
        'imageUrl': 'https://example.com/image.jpg',
        'distance': 5.2,
        'distanceLabel': '5.2 mi',
        'rating': 4.8,
        'category': 'landmark',
        'source': 'google',
      };

      final place = Place.fromJson(json);

      expect(place.id, '123');
      expect(place.name, 'Golden Gate Bridge');
      expect(place.latitude, 37.8199);
      expect(place.longitude, -122.4783);
      expect(place.distanceLabel, '5.2 mi');
    });

    test('toJson serializes Place correctly', () {
      const place = Place(
        id: '123',
        name: 'Golden Gate Bridge',
        latitude: 37.8199,
        longitude: -122.4783,
      );

      final json = place.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Golden Gate Bridge');
      expect(json['latitude'], 37.8199);
    });

    test('Place equality works correctly', () {
      const place1 = Place(id: '1', name: 'Test');
      const place2 = Place(id: '1', name: 'Test');
      const place3 = Place(id: '2', name: 'Other');

      expect(place1, equals(place2));
      expect(place1, isNot(equals(place3)));
    });
  });

  group('SearchResponse', () {
    test('fromJson creates SearchResponse correctly', () {
      final json = {
        'user_intent': 'find restaurants',
        'user_location': 'San Francisco',
        'response': 'Here are some restaurants...',
        'places': [
          {'name': 'Restaurant A'},
          {'name': 'Restaurant B'},
        ],
        'debug': {'request_id': 'abc123', 'execution_time_ms': 500},
      };

      final response = SearchResponse.fromJson(json);

      expect(response.userIntent, 'find restaurants');
      expect(response.userLocation, 'San Francisco');
      expect(response.places.length, 2);
      expect(response.debug?.requestId, 'abc123');
    });

    test('SearchRequest toJson works correctly', () {
      const request = SearchRequest(
        chatInput: 'Find coffee shops',
        force: true,
      );

      final json = request.toJson();

      expect(json['chat_input'], 'Find coffee shops');
      expect(json['force'], true);
    });
  });

  group('DebugInfo', () {
    test('fromJson creates DebugInfo correctly', () {
      final json = {
        'request_id': 'req-123',
        'execution_time_ms': 250,
        'cache': {'hit': true, 'key': 'cache-key'},
      };

      final debug = DebugInfo.fromJson(json);

      expect(debug.requestId, 'req-123');
      expect(debug.executionTimeMs, 250);
      expect(debug.cache?.hit, true);
    });
  });
}
