import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:underfoot_mobile/data/models/models.dart';
import 'package:underfoot_mobile/presentation/widgets/place_card.dart';

void main() {
  group('PlaceCard Widget', () {
    testWidgets('renders place information correctly', (
      WidgetTester tester,
    ) async {
      const place = Place(name: 'Golden Gate Bridge', distanceLabel: '5.2 mi');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlaceCard(place: place)),
        ),
      );

      expect(find.text('Golden Gate Bridge'), findsOneWidget);
      expect(find.text('5.2 mi'), findsOneWidget);
    });

    testWidgets('shows selection state', (WidgetTester tester) async {
      const place = Place(name: 'Test Place');
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaceCard(
              place: place,
              isSelected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PlaceCard));
      expect(tapped, true);
    });

    testWidgets('displays placeholder when no image', (
      WidgetTester tester,
    ) async {
      const place = Place(name: 'No Image Place');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlaceCard(place: place)),
        ),
      );

      expect(find.byIcon(Icons.place), findsOneWidget);
    });
  });
}
