import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/onboarding/ui/onboarding_screen.dart';
import 'package:mobile/fixtures/onboarding_fixtures.dart';

void main() {
  group('OnboardingScreen Widget Tests', () {
    testWidgets('renders welcome step with local privacy pledge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: OnboardingScreen(vm: OnboardingFixtures.welcome),
          ),
        ),
      );

      expect(find.text('Personal diet planning with foods you actually cook'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('renders cooking richness selection with Light, Normal, and Rich cards', (tester) async {
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

    testWidgets('renders target summary step with daily calorie target', (tester) async {
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
