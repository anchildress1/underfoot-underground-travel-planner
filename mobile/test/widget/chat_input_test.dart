import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:underfoot_mobile/presentation/widgets/chat_input.dart';

void main() {
  group('ChatInput Widget', () {
    testWidgets('renders input field and send button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChatInput(onSend: (_) {})),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('sends message when button tapped', (
      WidgetTester tester,
    ) async {
      var messageSent = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(onSend: (message) => messageSent = message),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      expect(messageSent, 'Test message');
    });

    testWidgets('clears input after sending', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChatInput(onSend: (_) {})),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('respects enabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ChatInput(onSend: (_) {}, enabled: false)),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('does not send empty messages', (WidgetTester tester) async {
      var messageSent = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatInput(onSend: (message) => messageSent = message),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      expect(messageSent, isEmpty);
    });
  });
}
