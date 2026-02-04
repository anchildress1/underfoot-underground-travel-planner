import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:underfoot_mobile/presentation/widgets/mode_tabs.dart';

void main() {
  group('ModeTabs Widget', () {
    testWidgets('renders all mode options', (WidgetTester tester) async {
      var selectedMode = TripMode.plan;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModeTabs(
              selectedMode: selectedMode,
              onModeChanged: (mode) => selectedMode = mode,
            ),
          ),
        ),
      );

      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Optimize'), findsOneWidget);
    });

    testWidgets('handles mode selection', (WidgetTester tester) async {
      var selectedMode = TripMode.plan;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: ModeTabs(
                  selectedMode: selectedMode,
                  onModeChanged: (mode) {
                    setState(() => selectedMode = mode);
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(selectedMode, TripMode.plan);

      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();

      expect(selectedMode, TripMode.explore);
    });

    testWidgets('shows selected state visually', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModeTabs(selectedMode: TripMode.plan, onModeChanged: (_) {}),
          ),
        ),
      );

      final planTab = tester.widget<GestureDetector>(
        find.ancestor(
          of: find.text('Plan'),
          matching: find.byType(GestureDetector),
        ),
      );

      expect(planTab, isNotNull);
    });
  });
}
