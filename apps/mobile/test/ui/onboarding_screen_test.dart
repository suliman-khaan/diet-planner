import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/onboarding/ui/onboarding_screen.dart';
import 'package:mobile/features/onboarding/view_model/onboarding_view_model.dart';
import 'package:mobile/fixtures/onboarding_fixtures.dart';

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('renders welcome step with local privacy pledge',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: OnboardingScreen(vm: OnboardingFixtures.welcome),
          ),
        ),
      );

      expect(find.text('Personal diet planning with foods you actually cook'),
          findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('renders about you step with interactive height and weight',
        (tester) async {
      double? changedHeight;
      double? changedWeight;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingScreen(
              vm: OnboardingFixtures.aboutYou,
              onHeightChanged: (h) => changedHeight = h,
              onWeightChanged: (w) => changedWeight = w,
            ),
          ),
        ),
      );

      expect(find.text('About you'), findsOneWidget);
      expect(find.text('Biological Sex'), findsOneWidget);
      expect(find.text('Height'), findsOneWidget);
      expect(find.text('Tap to scroll ft & in'), findsOneWidget);
      expect(find.text('Current Weight'), findsOneWidget);

      // Verify weight stepper plus button adjusts weight
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      expect(changedWeight, 73.0);

      // Verify tapping height tile opens wheel picker sheet
      await tester.tap(find.text('Tap to scroll ft & in'));
      await tester.pumpAndSettle();

      expect(find.text('Scroll to Set Height'), findsOneWidget);
      expect(find.text('Feet (ft)'), findsOneWidget);
      expect(find.text('Inches (in)'), findsOneWidget);
      expect(find.text('Set Height'), findsOneWidget);

      // Confirm height selection
      await tester.tap(find.text('Set Height'));
      await tester.pumpAndSettle();
      expect(changedHeight, isNotNull);
    });

    testWidgets(
        'renders dietary step with selectable diet type and allergy chips',
        (tester) async {
      DietType? selectedDiet;
      String? toggledAllergy;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: OnboardingScreen(
              vm: OnboardingFixtures.dietary,
              onDietTypeChanged: (d) => selectedDiet = d,
              onAllergyToggled: (a) => toggledAllergy = a,
            ),
          ),
        ),
      );

      expect(find.text('Dietary preferences & allergies'), findsOneWidget);
      expect(find.text('Everything (Halal)'), findsOneWidget);
      expect(find.text('Vegetarian'), findsOneWidget);
      expect(find.text('Vegan'), findsOneWidget);
      expect(find.text('Gluten Sensitive'), findsOneWidget);

      // Select Vegetarian
      await tester.tap(find.text('Vegetarian'));
      await tester.pumpAndSettle();
      expect(selectedDiet, DietType.vegetarian);

      // Toggle Gluten
      await tester.tap(find.text('Gluten Sensitive'));
      await tester.pumpAndSettle();
      expect(toggledAllergy, 'gluten');
    });

    testWidgets(
        'renders cooking richness selection with Light, Normal, and Rich cards',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: OnboardingScreen(vm: OnboardingFixtures.cookingRichness),
          ),
        ),
      );

      expect(find.text('How rich is your home cooking?'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Rich'), findsOneWidget);
      expect(find.text('Most common'), findsOneWidget);
    });

    testWidgets('renders target summary step with daily calorie target',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: OnboardingScreen(vm: OnboardingFixtures.targetSummary),
          ),
        ),
      );

      expect(find.text('Your Daily Nutrition Target'), findsOneWidget);
      expect(find.text('~1850'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Start my plan'), findsOneWidget);
    });
  });
}
