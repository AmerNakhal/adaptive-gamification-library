import 'package:adaptive_gamification/adaptive_gamification.dart';

abstract class ExampleFormatters {
  static String formatDouble(
      double? value, {
        int fractionDigits = 2,
        String fallback = '—',
      }) {
    if (value == null) return fallback;
    return value.toStringAsFixed(fractionDigits);
  }

  static String formatInt(
      int? value, {
        String fallback = '—',
      }) {
    if (value == null) return fallback;
    return value.toString();
  }

  static String formatPercent(
      double? value, {
        int fractionDigits = 1,
        String fallback = '—',
      }) {
    if (value == null) return fallback;
    return '${(value * 100).toStringAsFixed(fractionDigits)}%';
  }

  static String formatDateTime(
      DateTime? value, {
        String fallback = '—',
      }) {
    if (value == null) return fallback;
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  static String formatDuration(
      Duration? value, {
        String fallback = '—',
      }) {
    if (value == null) return fallback;

    final totalSeconds = value.inSeconds.abs();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  static String formatAdaptiveState(
      AdaptiveState? state, {
        String fallback = '—',
      }) {
    if (state == null) return fallback;
    return 'E:${state.engagement.toStringAsFixed(2)}  '
        'M:${state.motivation.toStringAsFixed(2)}  '
        'F:${state.flow.toStringAsFixed(2)}  '
        'P:${state.performance.toStringAsFixed(2)}';
  }

  static String formatDecisionSummary(
      AdaptiveDecision? decision, {
        String fallback = '—',
      }) {
    if (decision == null) return fallback;

    final action = decision.actionLabel == null || decision.actionLabel!.trim().isEmpty
        ? 'n/a'
        : decision.actionLabel!;

    final reason = decision.reason == null || decision.reason!.trim().isEmpty
        ? ''
        : ' • ${decision.reason}';

    return 'nextDifficulty=${decision.nextDifficulty} • '
        'source=${decision.source} • '
        'action=$action$reason';
  }

  static String formatRecommendationSummary(
      AdaptiveRecommendation? recommendation, {
        String fallback = '—',
      }) {
    if (recommendation == null) return fallback;

    return '${recommendation.title} • '
        '${recommendation.priority} • '
        '${recommendation.type}';
  }

  static String formatTransitionSummary(
      DifficultyTransition? transition, {
        String fallback = '—',
      }) {
    if (transition == null) return fallback;

    return '${transition.beforeLevel} (${transition.beforeRank}) → '
        '${transition.afterLevel} (${transition.afterRank}) • '
        '${transition.changeType} • '
        'Δ ${transition.delta}';
  }

  static String formatSessionStatisticsSummary(
      SessionStatistics? statistics, {
        String fallback = '—',
      }) {
    if (statistics == null) return fallback;

    return 'interactions=${statistics.interactionCount}, '
        'success=${statistics.successfulCount}, '
        'failure=${statistics.unsuccessfulCount}, '
        'avgScore=${formatDouble(statistics.averageScore)}';
  }

  static String formatTags(
      List<String> tags, {
        String fallback = '—',
      }) {
    if (tags.isEmpty) return fallback;
    return tags.join(' • ');
  }
}