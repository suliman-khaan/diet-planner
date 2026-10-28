import 'food.dart';

/// Search over English names, Urdu names and Roman Urdu aliases. Roman Urdu has no fixed
/// spelling ("chana chaat", "chana chat", "chanay ki chaat"), so text is normalised and
/// small spelling differences are tolerated.
class FoodSearch {
  FoodSearch(this.foods)
      : _index = [
          for (final f in foods)
            _Entry(f, {
              _normalise(f.nameEn),
              for (final a in f.romanUrduAliases) _normalise(a),
            }, f.nameUr ?? ''),
        ];

  final List<Food> foods;
  final List<_Entry> _index;

  /// Best matches first. An empty query returns all foods in [category] alphabetically.
  List<Food> search(String query, {String? category}) {
    final inCategory = _index.where((e) => category == null || e.food.category == category);
    final q = _normalise(query);
    if (query.trim().isEmpty) {
      return inCategory.map((e) => e.food).toList()..sort((a, b) => a.nameEn.compareTo(b.nameEn));
    }
    final scored = <(Food, int)>[];
    for (final e in inCategory) {
      final s = e.score(q, query.trim());
      if (s > 0) scored.add((e.food, s));
    }
    scored.sort((a, b) {
      final c = b.$2.compareTo(a.$2);
      return c != 0 ? c : a.$1.nameEn.compareTo(b.$1.nameEn);
    });
    return [for (final s in scored) s.$1];
  }

  /// Lowercase, letters and digits only, and common Roman Urdu spelling variants folded.
  static String _normalise(String s) {
    var t = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    t = t
        .replaceAll('aa', 'a')
        .replaceAll('ee', 'i')
        .replaceAll('oo', 'u')
        .replaceAll('ay', 'e')
        .replaceAll('ai', 'e')
        .replaceAll('w', 'v')
        .replaceAll('z', 'j')
        .replaceAll('q', 'k')
        .replaceAll('h', '');
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _Entry {
  _Entry(this.food, this.keys, this.urdu);

  final Food food;
  final Set<String> keys;
  final String urdu;

  int score(String q, String raw) {
    var best = 0;
    if (urdu.isNotEmpty && raw.isNotEmpty) {
      if (urdu == raw) return 100;
      if (urdu.contains(raw)) best = 90;
    }
    if (q.isEmpty) return best;
    final qTokens = q.split(' ');
    for (final k in keys) {
      if (k == q) return 100;
      if (k.startsWith(q)) best = best < 85 ? 85 : best;
      if (k.contains(q)) best = best < 70 ? 70 : best;
      final kTokens = k.split(' ');
      final allTokensMatch = qTokens.every((qt) => kTokens.any((kt) => _close(qt, kt)));
      if (allTokensMatch) best = best < 60 ? 60 : best;
    }
    return best;
  }

  static bool _close(String q, String k) {
    if (k.startsWith(q)) return true;
    if (q.length < 4) return false;
    return _editDistanceAtMostOne(q, k.length > q.length ? k.substring(0, q.length) : k) ||
        _editDistanceAtMostOne(q, k);
  }

  static bool _editDistanceAtMostOne(String a, String b) {
    if ((a.length - b.length).abs() > 1) return false;
    var i = 0, j = 0, edits = 0;
    while (i < a.length && j < b.length) {
      if (a[i] == b[j]) {
        i++;
        j++;
        continue;
      }
      if (++edits > 1) return false;
      if (a.length > b.length) {
        i++;
      } else if (b.length > a.length) {
        j++;
      } else {
        i++;
        j++;
      }
    }
    return edits + (a.length - i) + (b.length - j) <= 1;
  }
}
