import 'dart:convert';

import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PolicyAssetLoader {
  const PolicyAssetLoader();

  Future<String> loadRawJson(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    if (raw.trim().isEmpty) {
      throw FlutterError(
        'Policy asset at "$assetPath" is empty.',
      );
    }
    return raw;
  }

  Future<Map<String, dynamic>> loadJsonMap(String assetPath) async {
    final raw = await loadRawJson(assetPath);

    final dynamic decoded;
    try {
      decoded = json.decode(raw);
    } catch (error) {
      throw FlutterError(
        'Failed to decode policy asset "$assetPath" as JSON: $error',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw FlutterError(
        'Policy asset "$assetPath" must decode to Map<String, dynamic>.',
      );
    }

    return decoded;
  }

  Future<AdaptiveGamificationLibrary> loadLibraryFromAsset(
      String assetPath, {
        LibraryConfig config = const LibraryConfig(),
      }) async {
    final library = AdaptiveGamificationLibrary(config: config);
    final map = await loadJsonMap(assetPath);
    library.initializeFromMap(map);
    return library;
  }
}