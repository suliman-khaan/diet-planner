// On-device smoke test. Needs a phone or emulator:
//   flutter test integration_test --flavor dev -t lib/main_dev.dart -d <device>
// CI runs the same flows headless in test/features/app_flow_test.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/app/app_config.dart';
import 'package:mobile/app/bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start reaches onboarding or Today within the 2.5 s budget', (tester) async {
    final stopwatch = Stopwatch()..start();
    await bootstrap(const AppConfig(flavor: Flavor.dev));
    // Wait for the first real screen (onboarding welcome or the Today tab).
    final firstScreen = find.byWidgetPredicate(
      (w) => w is Text && (w.data == 'Get started' || w.data == 'Diet Planner'),
    );
    for (var i = 0; i < 100 && firstScreen.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    stopwatch.stop();
    expect(firstScreen, findsWidgets);
    // Budget from blueprint §9, measured on the baseline 2–3 GB RAM phone.
    expect(stopwatch.elapsedMilliseconds, lessThan(2500), reason: 'cold start ${stopwatch.elapsedMilliseconds} ms');
  });
}
