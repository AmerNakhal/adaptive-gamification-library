import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AdaptiveGamificationExampleApp());
}

class AdaptiveGamificationExampleApp extends StatelessWidget {
  const AdaptiveGamificationExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Gamification Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  final AdaptiveEngine _engine = AdaptiveEngine();

  bool _loading = true;
  String _error = '';

  int _difficultyIndex = 2;
  int _streak = 0;
  int _total = 0;
  int _correct = 0;
  double _responseTime = 4.0;

  AdaptiveDecision? _lastDecision;

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  Future<void> _initEngine() async {
    try {
      await _engine.initFromAsset(
        policyAssetPath: 'assets/adaptive_policy_seed_42.json',
      );

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  double get _accuracy => ((_correct + 1) / (_total + 2)).clamp(0.0, 1.0);

  String _difficultyLabelFromIndex(int i) {
    const labels = ['veryEasy', 'easy', 'medium', 'hard', 'veryHard'];
    if (i < 0) return labels.first;
    if (i >= labels.length) return labels.last;
    return labels[i];
  }

  int _difficultyIndexFromLabel(String label) {
    const labels = ['veryEasy', 'easy', 'medium', 'hard', 'veryHard'];
    final index = labels.indexOf(label);
    return index == -1 ? 2 : index;
  }

  void _applyDecision(String nextDifficulty) {
    final target = _difficultyIndexFromLabel(nextDifficulty);
    final current = _difficultyIndex;

    if (target == current) return;

    if (target > current) {
      _difficultyIndex = (current + 1).clamp(0, 4);
    } else {
      _difficultyIndex = (current - 1).clamp(0, 4);
    }
  }

  Future<void> _answer(bool isCorrect) async {
    setState(() {
      _total += 1;
      if (isCorrect) {
        _correct += 1;
        _streak += 1;
      } else {
        _streak = 0;
      }
    });

    final userState = UserState(
      currentDifficultyIndex: _difficultyIndex,
      accuracy: _accuracy,
      responseTime: _responseTime,
      correctStreak: _streak,
    );

    final decision = _engine.decide(userState);

    setState(() {
      _lastDecision = decision;
      _applyDecision(decision.nextDifficulty);
    });
  }

  void _reset() {
    setState(() {
      _difficultyIndex = 2;
      _streak = 0;
      _total = 0;
      _correct = 0;
      _responseTime = 4.0;
      _lastDecision = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Adaptive Gamification Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            'Failed to initialize engine:\n\n$_error',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    final currentDifficulty = _difficultyLabelFromIndex(_difficultyIndex);
    final metadata = _engine.metadata;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Gamification Example'),
        actions: [
          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset session',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Policy Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Structured Format', value: _engine.isStructuredFormat ? 'Yes' : 'No'),
                _InfoRow(label: 'Policy Size', value: _engine.policySize.toString()),
                _InfoRow(label: 'Format Version', value: '${metadata['format_version'] ?? '-'}'),
                _InfoRow(label: 'Policy Type', value: '${metadata['policy_type'] ?? '-'}'),
                _InfoRow(label: 'Grid Resolution', value: '${metadata['grid_resolution'] ?? '-'}'),
                _InfoRow(label: 'State Decimals', value: '${metadata['state_decimals'] ?? '-'}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Current Session State',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Difficulty', value: currentDifficulty),
                _InfoRow(label: 'Accuracy', value: '${(_accuracy * 100).toStringAsFixed(1)}%'),
                _InfoRow(label: 'Correct Streak', value: _streak.toString()),
                _InfoRow(label: 'Answered', value: '$_total'),
                _InfoRow(label: 'Correct', value: _correct.toString()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Response Time (seconds)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _responseTime.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _responseTime,
                  min: 1.0,
                  max: 20.0,
                  divisions: 38,
                  label: _responseTime.toStringAsFixed(2),
                  onChanged: (value) {
                    setState(() {
                      _responseTime = value;
                    });
                  },
                ),
                const Text(
                  'This simulates how quickly the learner responds. Lower response time generally indicates higher responsiveness.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Latest Adaptive Decision',
            child: _lastDecision == null
                ? const Text('Answer a question to generate the first adaptive decision.')
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HighlightedDecision(nextDifficulty: _lastDecision!.nextDifficulty),
                const SizedBox(height: 10),
                _InfoRow(label: 'Reason', value: _lastDecision!.reason),
                _InfoRow(
                  label: 'Support Strategy',
                  value: _lastDecision!.supportStrategy ?? '-',
                ),
                _InfoRow(
                  label: 'Source Action',
                  value: _lastDecision!.sourceActionName ?? '-',
                ),
                _InfoRow(
                  label: 'Lookup Key',
                  value: _lastDecision!.lookupKey ?? '-',
                ),
                _InfoRow(
                  label: 'Exact Match',
                  value: _lastDecision!.foundExactMatch ? 'Yes' : 'No (fallback)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _answer(true),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Correct'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => _answer(false),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Wrong'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: this example applies at most one difficulty-level step per answer in the UI. The exported policy still provides the full target recommendation, but the demo smooths visible transitions for readability.',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label)),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedDecision extends StatelessWidget {
  final String nextDifficulty;

  const _HighlightedDecision({required this.nextDifficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_alt_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Recommended next difficulty: $nextDifficulty',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
