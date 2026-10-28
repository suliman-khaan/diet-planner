import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/meal/ui/meal_detail_screen.dart';
import 'package:mobile/fixtures/meal_fixtures.dart';

void main() {
  group('MealDetailScreen Widget Tests', () {
    testWidgets('renders family pot dish with steppers and oil selector',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: MealDetailScreen(vm: MealFixtures.dinnerSuccess),
          ),
        ),
      );

      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Chicken karahi'), findsOneWidget);
      expect(find.text('Family pot'), findsOneWidget);
      expect(find.text('Oil in this dish'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Tandoori roti'), findsOneWidget);
      expect(find.text('Add food'), findsOneWidget);
      expect(find.text('Replace dish'), findsOneWidget);
    });

    testWidgets('renders eaten meal state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: MealDetailScreen(vm: MealFixtures.dinnerEaten),
          ),
        ),
      );

      expect(find.text('Mark as planned'), findsOneWidget);
    });
  });
}
