import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads an exported adaptive policy JSON and builds a fast lookup index.
///
/// Supported formats:
///
/// 1) New format (preferred)
///
/// ```json
/// {
///   "metadata": { ... },
///   "policy": {
///     "eng=0.25|mot=0.50|flow=0.75|perf=1.00": {
///       "state": { "eng": ..., "mot": ..., "flow": ..., "perf": ... },
///       "action": 2,
///       "decision": { ... },
///       "probs": [ ... ],
///       "value": 0.123
///     }
///   }
/// }
/// ```
///
/// 2) Legacy format (backward compatibility)
///
/// ```json
/// [
///   {
///     "state": { "eng": ..., "mot": ..., "flow": ..., "perf": ... },
///     "decision": { ... }
///   }
/// ]
/// ```
///
/// In the new format, the runtime key format is:
///
/// `eng=0.25|mot=0.50|flow=0.75|perf=1.00`
class PolicyLoader {
  /// Parsed metadata from the exported policy file.
  ///
  /// Example fields may include:
  /// - `format_version`
  /// - `policy_type`
  /// - `state_order`
  /// - `state_decimals`
  /// - `grid_resolution`
  Map<String, dynamic> metadata = <String, dynamic>{};

  /// Key -> full policy entry.
  ///
  /// Each entry may include:
  /// - `state`
  /// - `action`
  /// - `decision`
  /// - `probs`
  /// - `value`
  final Map<String, Map<String, dynamic>> index =
  <String, Map<String, dynamic>>{};

  /// Raw parsed entries for debugging or inspection.
  ///
  /// For the new format this is derived from `policy.values`.
  /// For the legacy format this is the parsed list.
  List<Map<String, dynamic>> raw = <Map<String, dynamic>>[];

  /// Whether the last-loaded policy used the new structured format.
  bool isStructuredFormat = false;

  /// Loads policy JSON from a Flutter asset.
  Future<void> loadFromAsset(
      String assetPath, {
        AssetBundle? bundle,
      }) async {
    final AssetBundle b = bundle ?? rootBundle;
    final String jsonString = await b.loadString(assetPath);
    loadFromString(jsonString);
  }

  /// Loads policy JSON from a raw string and builds the lookup index.
  void loadFromString(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);

    metadata = <String, dynamic>{};
    raw = <Map<String, dynamic>>[];
    index.clear();
    isStructuredFormat = false;

    if (decoded is Map<dynamic, dynamic>) {
      _loadStructuredFormat(_toStringKeyMap(decoded));
      return;
    }

    if (decoded is List<dynamic>) {
      _loadLegacyFormat(decoded);
      return;
    }

    throw const FormatException(
      'Policy JSON must be either a structured object with metadata/policy '
          'or a legacy List of entries.',
    );
  }

  void _loadStructuredFormat(Map<String, dynamic> decoded) {
    final Map<String, dynamic>? meta = _asStringKeyMap(decoded['metadata']);
    final Map<String, dynamic>? policyMap = _asStringKeyMap(decoded['policy']);

    if (policyMap == null) {
      throw const FormatException(
        'Structured policy JSON must contain a top-level "policy" object.',
      );
    }

    metadata = meta ?? <String, dynamic>{};
    isStructuredFormat = true;

    final List<Map<String, dynamic>> rawEntries = <Map<String, dynamic>>[];

    policyMap.forEach((String key, dynamic value) {
      final Map<String, dynamic>? entry = _asStringKeyMap(value);
      if (entry == null) return;

      final Map<String, dynamic> normalizedEntry =
      Map<String, dynamic>.from(entry);
      normalizedEntry['_key'] = key;

      rawEntries.add(normalizedEntry);
      index[key] = normalizedEntry;
    });

    raw = rawEntries;
  }

  void _loadLegacyFormat(List<dynamic> decoded) {
    raw = decoded
        .whereType<Map<dynamic, dynamic>>()
        .map<Map<String, dynamic>>(_toStringKeyMap)
        .toList();

    for (final Map<String, dynamic> item in raw) {
      final Map<String, dynamic>? state = _asStringKeyMap(item['state']);
      if (state == null) continue;

      final double? eng = _asDouble(state['eng']);
      final double? mot = _asDouble(state['mot']);
      final double? flow = _asDouble(state['flow']);
      final double? perf = _asDouble(state['perf']);

      if (eng == null || mot == null || flow == null || perf == null) {
        continue;
      }

      final String key = buildStateKey(
        eng: eng,
        mot: mot,
        flow: flow,
        perf: perf,
        decimals: 2,
      );

      final Map<String, dynamic> normalizedEntry =
      Map<String, dynamic>.from(item);
      normalizedEntry['_key'] = key;

      index[key] = normalizedEntry;
    }
  }

  /// Returns the configured number of decimals used for state-key formatting.
  ///
  /// Defaults to `2` if metadata is absent.
  int get stateDecimals {
    final dynamic value = metadata['state_decimals'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 2;
  }

  /// Looks up the full policy entry by key.
  Map<String, dynamic>? getEntry(String key) => index[key];

  /// Looks up only the decision object by key.
  Map<String, dynamic>? getDecision(String key) {
    final Map<String, dynamic>? entry = index[key];
    if (entry == null) return null;
    return _asStringKeyMap(entry['decision']);
  }

  /// Builds a deployment key matching the Python export format.
  ///
  /// Example:
  ///
  /// `eng=0.25|mot=0.50|flow=0.75|perf=1.00`
  static String buildStateKey({
    required double eng,
    required double mot,
    required double flow,
    required double perf,
    int decimals = 2,
  }) {
    String format(double x) => x.toStringAsFixed(decimals);

    return 'eng=${format(eng)}|mot=${format(mot)}|flow=${format(flow)}|perf=${format(perf)}';
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return null;
  }

  static Map<String, dynamic>? _asStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map<dynamic, dynamic>) return _toStringKeyMap(value);
    return null;
  }

  static Map<String, dynamic> _toStringKeyMap(Map<dynamic, dynamic> input) {
    final Map<String, dynamic> out = <String, dynamic>{};
    input.forEach((dynamic key, dynamic value) {
      out[key.toString()] = value;
    });
    return out;
  }
}