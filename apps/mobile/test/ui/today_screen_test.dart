import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/today/ui/today_screen.dart';
import 'package:mobile/fixtures/today_fixtures.dart';

void main() {
  group('TodayScreen Widget Tests', () {
    testWidgets('renders standard mode with calories and next meal',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: TodayScreen(vm: TodayFixtures.standardSuccess),
          ),
        ),
      );

      // Verify header and calories
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('1,120'), findsWidgets);
      expect(find.text('kcal eaten'), findsOneWidget);

      // Verify next meal banner
      expect(find.text('Chicken karahi · 1 katori'), findsOneWidget);
      expect(find.text('Mark as eaten'), findsOneWidget);

      // Verify meals list items
      expect(
          find.textContaining('Breakfast', findRichText: true), findsWidgets);
      expect(find.textContaining('Lunch', findRichText: true), findsWidgets);
    });

    testWidgets('renders Ramadan mode with nocturnal styling and Sehri/Iftar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: TodayScreen(vm: TodayFixtures.ramadanSuccess),
          ),
        ),
      );

      expect(find.text('Ramadan · Day 22'), findsOneWidget);
      expect(find.textContaining('Sehri', findRichText: true), findsWidgets);
      expect(find.textContaining('Iftar', findRichText: true), findsWidgets);
    });

    testWidgets('renders empty state when no plan exists', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: TodayScreen(
                vm: TodayFixtures.emptyNoPlan, onGeneratePlan: _noop),
          ),
        ),
      );

      expect(find.text('No plan for today yet'), findsOneWidget);
      expect(find.text('Generate plan'), findsOneWidget);
    });

    testWidgets('renders error state with retry button', (tester) async {
      var retryClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TodayScreen(
              vm: TodayFixtures.error,
              onRetry: () => retryClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Could not load your plan for today. Please retry.'),
          findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      expect(retryClicked, isTrue);
    });
  });
}

void _noop() {}
