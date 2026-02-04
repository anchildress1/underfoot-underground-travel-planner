import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:underfoot_mobile/data/models/models.dart';
import 'package:underfoot_mobile/presentation/widgets/debug_panel.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget createDebugPanelTest({
    DebugInfo? debugInfo,
    bool isVisible = true,
    VoidCallback? onClose,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 800,
          child: DebugPanel(
            debugInfo: debugInfo,
            isVisible: isVisible,
            onClose: onClose ?? () {},
          ),
        ),
      ),
    );
  }

  group('DebugPanel Widget', () {
    testWidgets('renders nothing when not visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDebugPanelTest(isVisible: false));

      expect(find.text('AI Debug Console'), findsNothing);
    });

    testWidgets('renders empty state when visible but no data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDebugPanelTest(debugInfo: null));

      expect(find.text('AI Debug Console'), findsOneWidget);
      expect(find.text('No Debug Data Yet'), findsOneWidget);
    });

    testWidgets('renders debug info when provided', (
      WidgetTester tester,
    ) async {
      const debugInfo = DebugInfo(
        searchQuery: 'Find parks',
        executionTimeMs: 150,
        confidence: 0.85,
        keywords: ['parks', 'nature'],
        llmReasoning: 'Searching for outdoor spaces',
        dataSources: ['Google Places', 'OpenStreetMap'],
      );

      await tester.pumpWidget(createDebugPanelTest(debugInfo: debugInfo));

      expect(find.text('AI Debug Console'), findsOneWidget);
      expect(find.text('Find parks'), findsOneWidget);
      expect(find.text('150ms'), findsOneWidget);
      expect(find.text('85.0%'), findsOneWidget);
      expect(find.text('parks'), findsOneWidget);
      expect(find.text('nature'), findsOneWidget);
      expect(find.text('Searching for outdoor spaces'), findsOneWidget);
    });

    testWidgets('close button triggers callback', (WidgetTester tester) async {
      var closed = false;

      await tester.pumpWidget(
        createDebugPanelTest(onClose: () => closed = true),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, true);
    });

    testWidgets('renders cache hit status', (WidgetTester tester) async {
      const debugInfo = DebugInfo(cache: CacheInfo(hit: true, key: 'test-key'));

      await tester.pumpWidget(createDebugPanelTest(debugInfo: debugInfo));

      expect(find.text('Cache Hit'), findsOneWidget);
    });

    testWidgets('renders geospatial data', (WidgetTester tester) async {
      const debugInfo = DebugInfo(
        geospatialData: GeospatialData(
          centerPoint: [37.7749, -122.4194],
          searchRadius: 5000,
        ),
      );

      await tester.pumpWidget(createDebugPanelTest(debugInfo: debugInfo));

      expect(find.text('Geospatial Data'), findsOneWidget);
      expect(find.text('37.7749, -122.4194'), findsOneWidget);
      expect(find.text('5000m'), findsOneWidget);
    });
  });
}
