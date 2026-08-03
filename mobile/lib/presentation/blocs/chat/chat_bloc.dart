import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/search_repository.dart';
import '../../../data/services/api_service.dart';
import 'chat_event.dart';
import 'chat_message.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SearchRepository _repository;

  ChatBloc({SearchRepository? repository})
    : _repository = repository ?? SearchRepository(),
      super(const ChatState()) {
    on<ChatMessageSent>(_onMessageSent);
    on<ChatCleared>(_onCleared);
    on<ChatPlaceSelected>(_onPlaceSelected);
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    if (kDebugMode) {
      debugPrint('💬 ChatBloc: Message sent: "${event.message}"');
    }
    final userMessage = ChatMessage.user(event.message);

    // Read state.messages fresh at each emit (not a snapshot captured
    // before the await) so concurrent in-flight sends don't clobber
    // each other's messages.
    emit(
      state.copyWith(
        status: ChatStatus.loading,
        messages: [...state.messages, userMessage],
      ),
    );

    try {
      if (kDebugMode) debugPrint('🔄 ChatBloc: Calling search repository...');
      final response = await _repository.search(
        event.message,
        userLocation: event.userLocation,
        force: event.force,
      );

      if (kDebugMode) {
        debugPrint('✅ ChatBloc: Got ${response.places.length} places');
      }
      final assistantMessage = ChatMessage.assistant(response);

      emit(
        state.copyWith(
          status: ChatStatus.success,
          messages: [...state.messages, assistantMessage],
        ),
      );
    } on ApiException catch (e) {
      if (kDebugMode) debugPrint('❌ ChatBloc: ApiException: ${e.message}');
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.message));
    } catch (e) {
      if (kDebugMode) debugPrint('❌ ChatBloc: Unknown error: $e');
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  void _onCleared(ChatCleared event, Emitter<ChatState> emit) {
    emit(const ChatState());
  }

  void _onPlaceSelected(ChatPlaceSelected event, Emitter<ChatState> emit) {
    final places = state.allPlaces;
    if (event.placeIndex >= 0 && event.placeIndex < places.length) {
      emit(state.copyWith(selectedPlace: places[event.placeIndex]));
    }
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}
