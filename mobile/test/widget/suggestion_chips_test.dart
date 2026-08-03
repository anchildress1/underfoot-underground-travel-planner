import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:underfoot_mobile/presentation/widgets/suggestion_chips.dart';

import '../test_setup.dart';

void main() {
  setUpAll(setupGoogleFontsForTests);

  group('SuggestionChips Widget', () {
    testWidgets('renders all suggestions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestionChips(
              suggestions: DefaultSuggestions.all,
              onChipTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Food nearby'), findsOneWidget);
      expect(find.text('Museums'), findsOneWidget);
      expect(find.text('Parks'), findsOneWidget);
      // 'Nightlife' was removed from default suggestions
    });

    testWidgets('calls onChipTap when tapped', (WidgetTester tester) async {
      String? tappedLabel;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestionChips(
              suggestions: DefaultSuggestions.all,
              onChipTap: (label) => tappedLabel = label,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Museums'));
      await tester.pumpAndSettle();

      expect(tappedLabel, 'Museums');
    });

    testWidgets('renders custom suggestions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestionChips(
              suggestions: const [
                SuggestionChip(label: 'Custom 1', icon: Icons.star),
                SuggestionChip(label: 'Custom 2', icon: Icons.favorite),
              ],
              onChipTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Custom 1'), findsOneWidget);
      expect(find.text('Custom 2'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('chips have proper semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuggestionChips(
              suggestions: const [
                SuggestionChip(label: 'Test', icon: Icons.star),
              ],
              onChipTap: (_) {},
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.text('Test'));
      expect(semantics.label, contains('Test'));
    });
  });
}
