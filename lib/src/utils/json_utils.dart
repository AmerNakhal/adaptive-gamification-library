/// Utility helpers for safely reading JSON-like map structures.
abstract class JsonUtils {
  /// Returns whether [map] contains [key].
  static bool hasKey(Map<String, dynamic> map, String key) {
    return map.containsKey(key);
  }

  /// Reads a required string field.
  static String requireString(
      Map<String, dynamic> map,
      String key,
      ) {
    if (!map.containsKey(key)) {
      throw FormatException('Missing required field: $key');
    }

    final value = map[key];
    if (value is! String) {
      throw FormatException(
        'Field "$key" must be a String, but got ${value.runtimeType}.',
      );
    }

    return value;
  }

  /// Reads an optional string field.
  static String? readString(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return null;

    if (value is! String) {
      throw FormatException(
        'Field "$key" must be a String when provided, but got ${value.runtimeType}.',
      );
    }

    return value;
  }

  /// Reads a required boolean field.
  static bool requireBool(
      Map<String, dynamic> map,
      String key,
      ) {
    if (!map.containsKey(key)) {
      throw FormatException('Missing required field: $key');
    }

    final value = map[key];
    if (value is! bool) {
      throw FormatException(
        'Field "$key" must be a bool, but got ${value.runtimeType}.',
      );
    }

    return value;
  }

  /// Reads an optional boolean field.
  static bool? readBool(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return null;

    if (value is! bool) {
      throw FormatException(
        'Field "$key" must be a bool when provided, but got ${value.runtimeType}.',
      );
    }

    return value;
  }

  /// Reads a required numeric field as double.
  static double requireDouble(
      Map<String, dynamic> map,
      String key,
      ) {
    if (!map.containsKey(key)) {
      throw FormatException('Missing required field: $key');
    }

    final value = map[key];
    if (value is! num) {
      throw FormatException(
        'Field "$key" must be numeric, but got ${value.runtimeType}.',
      );
    }

    return value.toDouble();
  }

  /// Reads an optional numeric field as double.
  static double? readDouble(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return null;

    if (value is! num) {
      throw FormatException(
        'Field "$key" must be numeric when provided, but got ${value.runtimeType}.',
      );
    }

    return value.toDouble();
  }

  /// Reads a required numeric field as int.
  static int requireInt(
      Map<String, dynamic> map,
      String key,
      ) {
    if (!map.containsKey(key)) {
      throw FormatException('Missing required field: $key');
    }

    final value = map[key];
    if (value is! num) {
      throw FormatException(
        'Field "$key" must be numeric, but got ${value.runtimeType}.',
      );
    }

    return value.toInt();
  }

  /// Reads an optional numeric field as int.
  static int? readInt(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return null;

    if (value is! num) {
      throw FormatException(
        'Field "$key" must be numeric when provided, but got ${value.runtimeType}.',
      );
    }

    return value.toInt();
  }

  /// Reads a required object field as Map<String, dynamic>.
  static Map<String, dynamic> requireObject(
      Map<String, dynamic> map,
      String key,
      ) {
    if (!map.containsKey(key)) {
      throw FormatException('Missing required field: $key');
    }

    final value = map[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException(
        'Field "$key" must be a Map<String, dynamic>, but got ${value.runtimeType}.',
      );
    }

    return value;
  }

  /// Reads an optional object field as Map<String, dynamic>.
  static Map<String, dynamic>? readObject(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return null;

    if (value is! Map<String, dynamic>) {
      throw FormatException(
        'Field "$key" must be a Map<String, dynamic> when provided, but got ${value.runtimeType}.',
      );
    }

    return value;
  }

  /// Reads a required list field.
  static List<dynamic> requireList(
      Map<String, dynamic> map,
      String key,
      ) {
    if (!map.containsKey(key)) {
      throw FormatException('Missing required field: $key');
    }

    final value = map[key];
    if (value is! List) {
      throw FormatException(
        'Field "$key" must be a List, but got ${value.runtimeType}.',
      );
    }

    return value;
  }

  /// Reads an optional list field.
  static List<dynamic>? readList(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return null;

    if (value is! List) {
      throw FormatException(
        'Field "$key" must be a List when provided, but got ${value.runtimeType}.',
      );
    }

    return value;
  }

  /// Reads a string list.
  static List<String> readStringList(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return const <String>[];

    if (value is! List) {
      throw FormatException(
        'Field "$key" must be a List when provided, but got ${value.runtimeType}.',
      );
    }

    final result = <String>[];
    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'Field "$key" must contain only String values, but found ${item.runtimeType}.',
        );
      }
      result.add(item);
    }

    return List<String>.unmodifiable(result);
  }

  /// Reads a string-to-string map.
  static Map<String, String> readStringMap(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return const <String, String>{};

    if (value is! Map) {
      throw FormatException(
        'Field "$key" must be a Map when provided, but got ${value.runtimeType}.',
      );
    }

    final result = <String, String>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! String) {
        throw FormatException(
          'Field "$key" must map String keys to String values.',
        );
      }
      result[entry.key as String] = entry.value as String;
    }

    return Map<String, String>.unmodifiable(result);
  }

  /// Reads a string-to-double map.
  static Map<String, double> readDoubleMap(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return const <String, double>{};

    if (value is! Map) {
      throw FormatException(
        'Field "$key" must be a Map when provided, but got ${value.runtimeType}.',
      );
    }

    final result = <String, double>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! num) {
        throw FormatException(
          'Field "$key" must map String keys to numeric values.',
        );
      }
      result[entry.key as String] = (entry.value as num).toDouble();
    }

    return Map<String, double>.unmodifiable(result);
  }

  /// Reads a string-to-bool map.
  static Map<String, bool> readBoolMap(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return const <String, bool>{};

    if (value is! Map) {
      throw FormatException(
        'Field "$key" must be a Map when provided, but got ${value.runtimeType}.',
      );
    }

    final result = <String, bool>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! bool) {
        throw FormatException(
          'Field "$key" must map String keys to bool values.',
        );
      }
      result[entry.key as String] = entry.value as bool;
    }

    return Map<String, bool>.unmodifiable(result);
  }

  /// Reads a list of doubles.
  static List<double> readDoubleList(
      Map<String, dynamic> map,
      String key,
      ) {
    final value = map[key];
    if (value == null) return const <double>[];

    if (value is! List) {
      throw FormatException(
        'Field "$key" must be a List when provided, but got ${value.runtimeType}.',
      );
    }

    final result = <double>[];
    for (final item in value) {
      if (item is! num) {
        throw FormatException(
          'Field "$key" must contain only numeric values, but found ${item.runtimeType}.',
        );
      }
      result.add(item.toDouble());
    }

    return List<double>.unmodifiable(result);
  }
}