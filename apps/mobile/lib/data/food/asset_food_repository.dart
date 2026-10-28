import '../../core/errors/app_failure.dart';
import '../../domain/food/food.dart';
import '../../domain/food/food_pack_parser.dart';
import '../../domain/repositories.dart';

/// Loads the food pack bundled with the app. It is always available offline.
class AssetFoodRepository implements FoodRepository {
  AssetFoodRepository(this._loadText);

  static const bundledPackAsset = 'assets/packs/pk-core.json';

  /// Reads the pack file, e.g. `() => rootBundle.loadString(bundledPackAsset)`.
  final Future<String> Function() _loadText;
  Future<FoodPack>? _cached;

  @override
  Future<FoodPack> loadPack() => _cached ??= _load();

  Future<FoodPack> _load() async {
    try {
      return FoodPackParser.parse(await _loadText());
    } on FormatException catch (e) {
      _cached = null;
      throw InvalidFoodPack(e.message);
    }
  }
}
