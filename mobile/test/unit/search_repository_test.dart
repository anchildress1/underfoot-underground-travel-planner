import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:underfoot_mobile/data/models/models.dart';
import 'package:underfoot_mobile/data/repositories/search_repository.dart';
import 'package:underfoot_mobile/data/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late SearchRepository repository;

  setUp(() {
    mockApiService = MockApiService();
    repository = SearchRepository(apiService: mockApiService);
  });

  group('SearchRepository', () {
    test('search delegates to ApiService', () async {
      const expectedResponse = SearchResponse(
        response: 'Test response',
        places: [],
      );

      when(
        () => mockApiService.search('test query', force: false),
      ).thenAnswer((_) async => expectedResponse);

      final result = await repository.search('test query');

      expect(result, expectedResponse);
      verify(() => mockApiService.search('test query', force: false)).called(1);
    });

    test('search passes force parameter', () async {
      const expectedResponse = SearchResponse(
        response: 'Test response',
        places: [],
      );

      when(
        () => mockApiService.search('test query', force: true),
      ).thenAnswer((_) async => expectedResponse);

      await repository.search('test query', force: true);

      verify(() => mockApiService.search('test query', force: true)).called(1);
    });

    test('checkHealth delegates to ApiService', () async {
      when(() => mockApiService.checkHealth()).thenAnswer((_) async => true);

      final result = await repository.checkHealth();

      expect(result, true);
      verify(() => mockApiService.checkHealth()).called(1);
    });

    test('dispose calls ApiService dispose', () {
      when(() => mockApiService.dispose()).thenReturn(null);

      repository.dispose();

      verify(() => mockApiService.dispose()).called(1);
    });

    test('propagates ApiException from search', () async {
      when(
        () => mockApiService.search(any(), force: any(named: 'force')),
      ).thenThrow(const ApiException(statusCode: 500, message: 'Error'));

      expect(() => repository.search('test'), throwsA(isA<ApiException>()));
    });
  });
}
