import 'app/app_config.dart';
import 'app/bootstrap.dart';

/// Production entry point (`--flavor prod -t lib/main.dart`).
Future<void> main() => bootstrap(const AppConfig(flavor: Flavor.prod));
