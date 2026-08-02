import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';
import 'chat_message.dart';

enum ChatStatus { initial, loading, success, error }

final class ChatState extends Equatable {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final Place? selectedPlace;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.selectedPlace,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    Place? selectedPlace,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      errorMessage: errorMessage,
    );
  }

  List<Place> get allPlaces {
    final places = <Place>[];
    for (final message in messages) {
      if (message.places != null) {
        places.addAll(message.places!);
      }
    }
    return places;
  }

  @override
  List<Object?> get props => [status, messages, selectedPlace, errorMessage];
}
