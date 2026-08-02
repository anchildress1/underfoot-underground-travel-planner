import 'package:equatable/equatable.dart';
import '../../../data/models/models.dart';

enum MessageRole { user, assistant }

class ChatMessage extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<Place>? places;
  final DebugInfo? debug;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.places,
    this.debug,
  });

  factory ChatMessage.user(String content) => ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    role: MessageRole.user,
    content: content,
    timestamp: DateTime.now(),
  );

  factory ChatMessage.assistant(SearchResponse response) => ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    role: MessageRole.assistant,
    content: response.response,
    timestamp: DateTime.now(),
    places: response.places,
    debug: response.debug,
  );

  @override
  List<Object?> get props => [id, role, content, timestamp, places, debug];
}
