import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:underfoot_mobile/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Underfoot App Integration Tests', () {
    testWidgets('Complete app navigation flow', (WidgetTester tester) async {
      await tester.pumpWidget(const UnderfootApp());
      await tester.pumpAndSettle();

      expect(find.text('Underfoot'), findsOneWidget);
      expect(find.text('Ready to explore?'), findsOneWidget);
    });

    testWidgets('Theme toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(const UnderfootApp());
      await tester.pumpAndSettle();

      final themeButton = find.byIcon(Icons.dark_mode);
      expect(themeButton, findsOneWidget);

      await tester.tap(themeButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('Chat input interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const UnderfootApp());
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Find coffee shops');
      await tester.pumpAndSettle();

      final sendButton = find.byIcon(Icons.arrow_upward);
      expect(sendButton, findsOneWidget);
    });

    testWidgets('Mode tabs interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const UnderfootApp());
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Optimize'), findsOneWidget);

      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
    });

    testWidgets('Suggestion chips render and are tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const UnderfootApp());
      await tester.pumpAndSettle();

      expect(find.text('Food nearby'), findsOneWidget);
      expect(find.text('Museums'), findsOneWidget);
      expect(find.text('Parks'), findsOneWidget);
      expect(find.text('Nightlife'), findsOneWidget);
    });

    testWidgets('Responsive layout switches correctly', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const UnderfootApp());
      await tester.pumpAndSettle();

      expect(find.text('Underfoot'), findsOneWidget);

      tester.view.physicalSize = const Size(375, 812);
      await tester.pumpAndSettle();

      expect(find.text('Underfoot'), findsOneWidget);
    });
  });
}
