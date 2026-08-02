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
    debugPrint('💬 ChatBloc: Message sent: "${event.message}" from location: ${event.userLocation}');
    final userMessage = ChatMessage.user(event.message);
    final updatedMessages = [...state.messages, userMessage];

    emit(state.copyWith(status: ChatStatus.loading, messages: updatedMessages));

    try {
      debugPrint('🔄 ChatBloc: Calling search repository...');
      final response = await _repository.search(
        event.message,
        userLocation: event.userLocation,
        force: event.force,
      );

      debugPrint('✅ ChatBloc: Got ${response.places.length} places');
      final assistantMessage = ChatMessage.assistant(response);
      final messagesWithResponse = [...updatedMessages, assistantMessage];

      emit(
        state.copyWith(
          status: ChatStatus.success,
          messages: messagesWithResponse,
        ),
      );
    } on ApiException catch (e) {
      debugPrint('❌ ChatBloc: ApiException: ${e.message}');
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.message));
    } catch (e) {
      debugPrint('❌ ChatBloc: Unknown error: $e');
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
