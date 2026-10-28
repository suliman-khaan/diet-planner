import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/progress/ui/progress_screen.dart';
import 'package:mobile/fixtures/progress_fixtures.dart';

void main() {
  group('ProgressScreen Widget Tests', () {
    testWidgets(
        'renders weight card, range toggle, eating bars, and metric cards',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: ProgressScreen(vm: ProgressFixtures.standardMonth),
          ),
        ),
      );

      expect(find.text('Weight & Consistency'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('78.4'), findsOneWidget);
      expect(find.text('Add weight'), findsOneWidget);
      expect(find.text("This week's eating"), findsOneWidget);
      expect(find.text('Days logged'), findsOneWidget);
      expect(find.text('Avg. protein'), findsOneWidget);
    });

    testWidgets('renders dark theme with contrast tokens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: ProgressScreen(vm: ProgressFixtures.standardMonth),
          ),
        ),
      );

      expect(find.text('Weight & Consistency'), findsOneWidget);
      expect(find.text('78.4'), findsOneWidget);
    });
  });
}
