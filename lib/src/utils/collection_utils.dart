/// Utility helpers for collection-oriented operations used across the library.
abstract class CollectionUtils {
  /// Returns an unmodifiable copy of [items].
  static List<T> immutableList<T>(Iterable<T> items) {
    return List<T>.unmodifiable(items);
  }

  /// Returns an unmodifiable copy of [map].
  static Map<K, V> immutableMap<K, V>(Map<K, V> map) {
    return Map<K, V>.unmodifiable(map);
  }

  /// Returns the first element that satisfies [test], or null if none match.
  static T? firstWhereOrNull<T>(
      Iterable<T> items,
      bool Function(T item) test,
      ) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Returns whether two lists are equal by ordered element comparison.
  static bool listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Returns whether two maps are equal by key/value comparison.
  static bool mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Returns whether two iterables contain the same ordered elements.
  static bool iterableEquals<T>(Iterable<T> a, Iterable<T> b) {
    final listA = a.toList(growable: false);
    final listB = b.toList(growable: false);
    return listEquals(listA, listB);
  }

  /// Returns a flattened list from nested iterables.
  static List<T> flatten<T>(Iterable<Iterable<T>> nested) {
    return List<T>.unmodifiable(
      nested.expand((items) => items),
    );
  }

  /// Returns a copy of [items] without null values.
  static List<T> compact<T>(Iterable<T?> items) {
    return List<T>.unmodifiable(
      items.whereType<T>(),
    );
  }

  /// Returns a new list containing distinct elements in original order.
  static List<T> distinct<T>(Iterable<T> items) {
    final seen = <T>{};
    final result = <T>[];

    for (final item in items) {
      if (seen.add(item)) {
        result.add(item);
      }
    }

    return List<T>.unmodifiable(result);
  }

  /// Returns a new map containing only entries whose values are non-null.
  static Map<K, V> compactMapValues<K, V>(
      Map<K, V?> map,
      ) {
    final result = <K, V>{};

    for (final entry in map.entries) {
      final value = entry.value;
      if (value != null) {
        result[entry.key] = value;
      }
    }

    return Map<K, V>.unmodifiable(result);
  }

  /// Returns the number of items that satisfy [test].
  static int countWhere<T>(
      Iterable<T> items,
      bool Function(T item) test,
      ) {
    var count = 0;
    for (final item in items) {
      if (test(item)) count++;
    }
    return count;
  }

  /// Returns whether [items] is null or empty.
  static bool isNullOrEmpty<T>(Iterable<T>? items) {
    return items == null || items.isEmpty;
  }

  /// Returns whether [map] is null or empty.
  static bool isMapNullOrEmpty<K, V>(Map<K, V>? map) {
    return map == null || map.isEmpty;
  }
}