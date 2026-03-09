import 'dart:convert';
import 'package:flutter/services.dart';

class AdaptiveEngine {
  late Map<String, int> _policy;
  Future<void> loadPolicy() async {
    final raw = await rootBundle.loadString('assets/data/adaptive_policy.json');
    final Map<String, dynamic> decoded = json.decode(raw);
    _policy = decoded.map((k, v) => MapEntry(k.toString(), int.parse(v.toString())));
  }
  int getAction(List<double> state) {
    final key = state.map((e) => e.toStringAsFixed(1)).join(',');
    return _policy.containsKey(key) ? _policy[key]! : 1; // default medium
  }
}