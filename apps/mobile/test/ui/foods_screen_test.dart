import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/foods/ui/foods_screen.dart';
import 'package:mobile/fixtures/foods_fixtures.dart';

void main() {
  group('FoodsScreen Widget Tests', () {
    testWidgets('renders search box, category chips and results list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: FoodsScreen(vm: FoodsFixtures.standardSearch),
          ),
        ),
      );

      expect(find.text('Foods'), findsOneWidget);
      expect(find.text('Chana chaat'), findsOneWidget);
      expect(find.text('Chana daal'), findsOneWidget);
      expect(find.text('4 results'), findsOneWidget);
      expect(find.text('Can\'t find a food? Tell us'), findsOneWidget);
    });

    testWidgets('renders empty state when search produces no results', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: FoodsScreen(vm: FoodsFixtures.emptySearch),
          ),
        ),
      );

      expect(find.text('No foods found'), findsOneWidget);
      expect(find.text('Suggest missing food'), findsOneWidget);
    });
  });
}
