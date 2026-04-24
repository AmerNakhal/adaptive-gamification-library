import 'package:adaptive_gamification/adaptive_gamification.dart';
import 'package:flutter/material.dart';

import '../core/example_constants.dart';
import '../shared/services/policy_asset_loader.dart';
import 'widgets/manual_decision_result_panel.dart';
import 'widgets/manual_state_input_form.dart';
import 'widgets/manual_trace_panel.dart';

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final _engagementController = TextEditingController(text: '0.40');
  final _motivationController = TextEditingController(text: '0.50');
  final _flowController = TextEditingController(text: '0.60');
  final _performanceController = TextEditingController(text: '0.70');
  final _difficultyRankController = TextEditingController(text: '2');

  final _policyAssetLoader = const PolicyAssetLoader();

  AdaptiveGamificationLibrary? _library;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedPolicyAsset = ExampleConstants.quizPolicyAsset;
  final String _sessionId =
      '${ExampleConstants.playgroundSessionPrefix}_${DateTime.now().millisecondsSinceEpoch}';

  AdaptiveState? _adaptiveState;
  AdaptiveDecision? _decision;
  AdaptiveRecommendation? _recommendation;
  DecisionTrace? _decisionTrace;
  AnalyticsSnapshot? _analyticsSnapshot;
  StateSnapshot? _stateSnapshot;
  String? _formattedExecutionTrace;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _engagementController.dispose();
    _motivationController.dispose();
    _flowController.dispose();
    _performanceController.dispose();
    _difficultyRankController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final library = await _policyAssetLoader.loadLibraryFromAsset(
        _selectedPolicyAsset,
        config: const LibraryConfig(
          diagnostics: DiagnosticsConfig(
            enableRuntimeDiagnostics: true,
          ),
        ),
      );

      setState(() {
        _library = library;
        _isLoading = false;
      });

      await _runPlayground();
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize playground: $error';
      });
    }
  }

  Future<void> _runPlayground() async {
    final library = _library;
    if (library == null || _isLoading) return;

    final engagement = double.tryParse(_engagementController.text.trim());
    final motivation = double.tryParse(_motivationController.text.trim());
    final flow = double.tryParse(_flowController.text.trim());
    final performance = double.tryParse(_performanceController.text.trim());
    final difficultyRank = int.tryParse(_difficultyRankController.text.trim());

    if (engagement == null ||
        motivation == null ||
        flow == null ||
        performance == null ||
        difficultyRank == null) {
      setState(() {
        _errorMessage = 'Please enter valid numeric values in all fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adaptiveState = AdaptiveState.clamped(
        engagement: engagement,
        motivation: motivation,
        flow: flow,
        performance: performance,
      );

      final interactionId =
          'playground_interaction_${DateTime.now().millisecondsSinceEpoch}';

      final executionResult = library.execute(
        state: adaptiveState,
        sessionId: _sessionId,
        interactionId: interactionId,
      );

      final recommendation = library.getRecommendation(
        state: adaptiveState,
        sessionId: _sessionId,
        interactionId: interactionId,
        currentDifficultyRank: difficultyRank,
      );

      final decisionTrace = library.getDecisionTrace(
        state: adaptiveState,
        sessionId: _sessionId,
        interactionId: interactionId,
        currentDifficultyRank: difficultyRank,
        note: 'Manual playground trace',
      );

      final formattedExecutionTrace = library.formatExecutionTrace(
        state: adaptiveState,
        sessionId: _sessionId,
        interactionId: interactionId,
        currentDifficultyRank: difficultyRank,
        phase: ExampleConstants.defaultRuntimePhase,
      );

      final stateSnapshot = StateSnapshot(
        state: adaptiveState,
        sessionId: _sessionId,
        timestamp: DateTime.now(),
      );

      final analyticsSnapshot = library.getAnalyticsSnapshot(
        _sessionId,
        latestTransition: recommendation.transition,
        decisionCount: 1,
        fallbackCount:
        executionResult.decision.source == DecisionSource.fallback
            ? 1
            : 0,
        scope: 'playground',
        note: 'Playground analytics snapshot',
        tags: const <String>['playground'],
        timestamp: DateTime.now(),
      ) ??
          AnalyticsSnapshot(
            snapshotId: 'playground_${DateTime.now().millisecondsSinceEpoch}',
            sessionId: _sessionId,
            scope: 'playground',
            stateSnapshot: stateSnapshot,
            latestTransition: recommendation.transition,
            latestRecommendation: recommendation,
            decisionCount: 1,
            fallbackCount:
            executionResult.decision.source == DecisionSource.fallback
                ? 1
                : 0,
            note: 'Playground analytics snapshot',
            tags: const <String>['playground'],
            timestamp: DateTime.now(),
          );

      setState(() {
        _adaptiveState = adaptiveState;
        _decision = executionResult.decision;
        _recommendation = recommendation;
        _decisionTrace = decisionTrace;
        _formattedExecutionTrace = formattedExecutionTrace;
        _stateSnapshot = stateSnapshot;
        _analyticsSnapshot = analyticsSnapshot;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to run playground execution: $error';
      });
    }
  }

  Future<void> _switchPolicyAsset(String assetPath) async {
    if (_selectedPolicyAsset == assetPath) return;

    setState(() {
      _selectedPolicyAsset = assetPath;
      _library = null;
      _adaptiveState = null;
      _decision = null;
      _recommendation = null;
      _decisionTrace = null;
      _formattedExecutionTrace = null;
      _stateSnapshot = null;
      _analyticsSnapshot = null;
      _errorMessage = null;
    });

    await _initialize();
  }

  @override
  Widget build(BuildContext context) {
    final hasError =
        _errorMessage != null && _errorMessage!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(ExampleConstants.playgroundTitle),
        actions: [
          IconButton(
            tooltip: 'Reload policy',
            onPressed: _isLoading ? null : _initialize,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: hasError
            ? _ErrorView(
          message: _errorMessage!,
          onRetry: _initialize,
        )
            : LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1100;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderBanner(
                        isLoading: _isLoading,
                        selectedPolicyAsset: _selectedPolicyAsset,
                        onPolicyChanged: _switchPolicyAsset,
                      ),
                      const SizedBox(height: 20),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  ManualStateInputForm(
                                    engagementController:
                                    _engagementController,
                                    motivationController:
                                    _motivationController,
                                    flowController: _flowController,
                                    performanceController:
                                    _performanceController,
                                    difficultyRankController:
                                    _difficultyRankController,
                                    onRun: _runPlayground,
                                    isLoading: _isLoading,
                                  ),
                                  const SizedBox(height: 16),
                                  ManualDecisionResultPanel(
                                    adaptiveState: _adaptiveState,
                                    decision: _decision,
                                    recommendation: _recommendation,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: ManualTracePanel(
                                decisionTrace: _decisionTrace,
                                formattedExecutionTrace:
                                _formattedExecutionTrace,
                                stateSnapshot: _stateSnapshot,
                                analyticsSnapshot: _analyticsSnapshot,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            ManualStateInputForm(
                              engagementController: _engagementController,
                              motivationController: _motivationController,
                              flowController: _flowController,
                              performanceController:
                              _performanceController,
                              difficultyRankController:
                              _difficultyRankController,
                              onRun: _runPlayground,
                              isLoading: _isLoading,
                            ),
                            const SizedBox(height: 16),
                            ManualDecisionResultPanel(
                              adaptiveState: _adaptiveState,
                              decision: _decision,
                              recommendation: _recommendation,
                            ),
                            const SizedBox(height: 16),
                            ManualTracePanel(
                              decisionTrace: _decisionTrace,
                              formattedExecutionTrace:
                              _formattedExecutionTrace,
                              stateSnapshot: _stateSnapshot,
                              analyticsSnapshot: _analyticsSnapshot,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final bool isLoading;
  final String selectedPolicyAsset;
  final ValueChanged<String> onPolicyChanged;

  const _HeaderBanner({
    required this.isLoading,
    required this.selectedPolicyAsset,
    required this.onPolicyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tune_outlined, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ExampleConstants.playgroundTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ExampleConstants.playgroundDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(isLoading ? 'Loading' : 'Ready'),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedPolicyAsset,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: ExampleConstants.quizPolicyAsset,
                  child: Text(
                    'Quiz policy',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: ExampleConstants.taskProgressionPolicyAsset,
                  child: Text(
                    'Task progression policy',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: isLoading
                  ? null
                  : (value) {
                if (value != null) {
                  onPolicyChanged(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Policy Asset',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Playground failed to initialize',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}