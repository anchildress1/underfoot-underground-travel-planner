import 'package:equatable/equatable.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

final class ChatMessageSent extends ChatEvent {
  final String message;
  final String? userLocation;
  final bool force;

  const ChatMessageSent(this.message, {this.userLocation, this.force = false});

  @override
  List<Object?> get props => [message, userLocation, force];
}

final class ChatCleared extends ChatEvent {
  const ChatCleared();
}

final class ChatPlaceSelected extends ChatEvent {
  final int placeIndex;

  const ChatPlaceSelected(this.placeIndex);

  @override
  List<Object?> get props => [placeIndex];
}
