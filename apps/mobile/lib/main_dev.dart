import 'app/app_config.dart';
import 'app/bootstrap.dart';

/// Development entry point (`--flavor dev -t lib/main_dev.dart`): draft food data allowed
/// (clearly labelled) and the screen gallery available.
Future<void> main() => bootstrap(const AppConfig(flavor: Flavor.dev));
