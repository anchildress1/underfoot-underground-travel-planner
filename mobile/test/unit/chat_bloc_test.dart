import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:underfoot_mobile/data/models/models.dart';
import 'package:underfoot_mobile/data/repositories/search_repository.dart';
import 'package:underfoot_mobile/presentation/blocs/chat/chat.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late MockSearchRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(false);
  });

  setUp(() {
    mockRepository = MockSearchRepository();
  });

  group('ChatBloc', () {
    blocTest<ChatBloc, ChatState>(
      'emits nothing when created',
      build: () => ChatBloc(repository: mockRepository),
      expect: () => [],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [loading, success] when message sent successfully',
      setUp: () {
        when(
          () => mockRepository.search(any(), force: any(named: 'force')),
        ).thenAnswer(
          (_) async =>
              const SearchResponse(response: 'Test response', places: []),
        );
      },
      build: () => ChatBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const ChatMessageSent('Hello')),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.status, 'status', ChatStatus.loading)
            .having((s) => s.messages.length, 'messages.length', 1),
        isA<ChatState>()
            .having((s) => s.status, 'status', ChatStatus.success)
            .having((s) => s.messages.length, 'messages.length', 2),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'emits [loading, error] when search fails',
      setUp: () {
        when(
          () => mockRepository.search(any(), force: any(named: 'force')),
        ).thenThrow(Exception('Network error'));
      },
      build: () => ChatBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const ChatMessageSent('Hello')),
      expect: () => [
        isA<ChatState>().having((s) => s.status, 'status', ChatStatus.loading),
        isA<ChatState>()
            .having((s) => s.status, 'status', ChatStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'clears messages when ChatCleared event',
      seed: () => ChatState(
        status: ChatStatus.success,
        messages: [ChatMessage.user('Test')],
      ),
      build: () => ChatBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const ChatCleared()),
      expect: () => [const ChatState()],
    );
  });
}
