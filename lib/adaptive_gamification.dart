library adaptive_gamification;

export 'src/adapters/default_state_adapter.dart';
export 'src/adapters/quiz_state_adapter.dart';
export 'src/adapters/state_adapter.dart';
export 'src/adapters/task_progression_state_adapter.dart';

export 'src/config/diagnostics_config.dart';
export 'src/config/fallback_strategy.dart';
export 'src/config/library_config.dart';
export 'src/config/runtime_config.dart';

export 'src/domain/analytics/analytics_snapshot.dart';
export 'src/domain/analytics/decision_trace.dart';
export 'src/domain/analytics/execution_trace.dart';
export 'src/domain/analytics/runtime_diagnostics.dart';

export 'src/domain/decisions/adaptive_decision.dart';
export 'src/domain/decisions/adaptive_decision_details.dart';
export 'src/domain/decisions/decision_context.dart';
export 'src/domain/decisions/decision_source.dart';

export 'src/domain/policy/exported_policy.dart';
export 'src/domain/policy/policy_entry.dart';
export 'src/domain/policy/policy_metadata.dart';
export 'src/domain/policy/policy_validation_result.dart';

export 'src/domain/recommendations/adaptive_recommendation.dart';
export 'src/domain/recommendations/recommendation_priority.dart';
export 'src/domain/recommendations/recommendation_type.dart';

export 'src/domain/sessions/adaptive_session_summary.dart';
export 'src/domain/sessions/interaction_event.dart';
export 'src/domain/sessions/session_snapshot.dart';
export 'src/domain/sessions/session_statistics.dart';
export 'src/domain/sessions/task_outcome.dart';

export 'src/domain/state/adaptive_state.dart';
export 'src/domain/state/state_dimension_labels.dart';
export 'src/domain/state/state_snapshot.dart';

export 'src/domain/transitions/difficulty_change_type.dart';
export 'src/domain/transitions/difficulty_level.dart';
export 'src/domain/transitions/difficulty_transition.dart';

export 'src/exceptions/adaptive_gamification_exception.dart';
export 'src/exceptions/policy_format_exception.dart';
export 'src/exceptions/policy_validation_exception.dart';
export 'src/exceptions/runtime_execution_exception.dart';
export 'src/exceptions/session_evaluation_exception.dart';

export 'src/facade/adaptive_gamification_library.dart';

export 'src/runtime/loaded_policy.dart';
export 'src/runtime/policy_loader.dart';
export 'src/runtime/policy_validator.dart';

export 'src/sessions/session_tracker.dart';