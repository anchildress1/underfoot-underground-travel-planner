import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:underfoot_mobile/presentation/blocs/chat/chat_message.dart';
import 'package:underfoot_mobile/presentation/widgets/message_bubble.dart';

void main() {
  group('MessageBubble Widget', () {
    testWidgets('renders user message correctly', (WidgetTester tester) async {
      final message = ChatMessage.user('Hello, world!');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      );

      expect(find.text('Hello, world!'), findsOneWidget);
    });

    testWidgets('renders assistant message correctly', (
      WidgetTester tester,
    ) async {
      final message = ChatMessage(
        id: '1',
        role: MessageRole.assistant,
        content: 'Here are some suggestions',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      );

      expect(find.text('Here are some suggestions'), findsOneWidget);
    });

    testWidgets('has proper semantics', (WidgetTester tester) async {
      final message = ChatMessage.user('Test message');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      );

      final semantics = tester.getSemantics(find.byType(MessageBubble));
      expect(semantics.label, contains('You'));
      expect(semantics.label, contains('Test message'));
    });
  });
}
