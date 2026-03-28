import 'package:flutter/services.dart';

import '../core/decision_engine.dart';
import '../core/policy_loader.dart';
import '../models/adaptive_decision.dart';
import '../models/user_state.dart';
import '../utils/state_mapper.dart';

/// High-level public entry point for the adaptive gamification package.
///
/// This class is responsible for:
/// - loading the exported policy
/// - building the runtime decision engine
/// - exposing policy metadata
/// - returning adaptive decisions for incoming [UserState] values
class AdaptiveEngine {
  final PolicyLoader _loader = PolicyLoader();
  DecisionEngine? _engine;

  /// Whether the engine has been initialized successfully.
  bool get isInitialized => _engine != null;

  /// Parsed export metadata, if available.
  Map<String, dynamic> get metadata => _loader.metadata;

  /// Whether the loaded JSON used the structured export format.
  bool get isStructuredFormat => _loader.isStructuredFormat;

  /// Raw parsed entries for optional debugging or inspection.
  List<Map<String, dynamic>> get rawEntries => _loader.raw;

  /// Number of indexed policy entries currently loaded.
  int get policySize => _loader.index.length;

  /// Initializes the engine from a Flutter asset.
  ///
  /// Example:
  /// `assets/data/adaptive_policy_seed_42.json`
  ///
  /// [grid] controls state discretization before policy lookup.
  Future<void> initFromAsset({
    required String policyAssetPath,
    AssetBundle? bundle,
    double grid = StateMapper.defaultGrid,
  }) async {
    await _loader.loadFromAsset(policyAssetPath, bundle: bundle);
    _buildDecisionEngine(grid: grid);
  }

  /// Initializes the engine from a raw JSON string.
  ///
  /// This is useful for:
  /// - backend-delivered policies
  /// - tests
  /// - dynamic loading scenarios
  ///
  /// [grid] controls state discretization before policy lookup.
  void initFromString(
      String jsonString, {
        double grid = StateMapper.defaultGrid,
      }) {
    _loader.loadFromString(jsonString);
    _buildDecisionEngine(grid: grid);
  }

  void _buildDecisionEngine({required double grid}) {
    _engine = DecisionEngine(
      _loader.index,
      stateDecimals: _loader.stateDecimals,
      grid: grid,
    );
  }

  /// Returns the adaptive decision for the provided runtime [state].
  ///
  /// Throws a [StateError] if the engine has not been initialized first.
  AdaptiveDecision decide(UserState state) {
    final DecisionEngine? engine = _engine;
    if (engine == null) {
      throw StateError(
        'AdaptiveEngine not initialized. Call initFromAsset/initFromString first.',
      );
    }
    return engine.decide(state);
  }
}