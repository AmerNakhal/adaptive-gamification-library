import 'package:adaptive_gamification/src/gamification/action_group_mapper.dart';
import 'package:adaptive_gamification/src/gamification/gamification_labels.dart';
import 'package:adaptive_gamification/src/gamification/support_strategy_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupportStrategyMapper', () {
    const mapper = SupportStrategyMapper();

    test('maps rest action to provide_recovery', () {
      expect(
        mapper.mapActionLabelToSupportStrategy(GamificationLabels.rest),
        GamificationLabels.provideRecovery,
      );
    });

    test('maps easy_task action to reduce_pressure', () {
      expect(
        mapper.mapActionLabelToSupportStrategy(GamificationLabels.easyTask),
        GamificationLabels.reducePressure,
      );
    });

    test('maps medium_task action to maintain_challenge', () {
      expect(
        mapper.mapActionLabelToSupportStrategy(GamificationLabels.mediumTask),
        GamificationLabels.maintainChallenge,
      );
    });

    test('maps hard_task action to increase_challenge', () {
      expect(
        mapper.mapActionLabelToSupportStrategy(GamificationLabels.hardTask),
        GamificationLabels.increaseChallenge,
      );
    });

    test('maps motivation_boost action to encourage_persistence', () {
      expect(
        mapper.mapActionLabelToSupportStrategy(
          GamificationLabels.motivationBoost,
        ),
        GamificationLabels.encouragePersistence,
      );
    });

    test('maps flow_task action to restore_flow', () {
      expect(
        mapper.mapActionLabelToSupportStrategy(GamificationLabels.flowTask),
        GamificationLabels.restoreFlow,
      );
    });

    test('maps recovery group to provide_recovery', () {
      expect(
        mapper.mapActionGroupToSupportStrategy(
          GamificationLabels.recoveryGroup,
        ),
        GamificationLabels.provideRecovery,
      );
    });

    test('maps challenge adjustment group to maintain_challenge', () {
      expect(
        mapper.mapActionGroupToSupportStrategy(
          GamificationLabels.challengeAdjustmentGroup,
        ),
        GamificationLabels.maintainChallenge,
      );
    });

    test('maps motivational support group to encourage_persistence', () {
      expect(
        mapper.mapActionGroupToSupportStrategy(
          GamificationLabels.motivationalSupportGroup,
        ),
        GamificationLabels.encouragePersistence,
      );
    });

    test('maps flow regulation group to restore_flow', () {
      expect(
        mapper.mapActionGroupToSupportStrategy(
          GamificationLabels.flowRegulationGroup,
        ),
        GamificationLabels.restoreFlow,
      );
    });

    test('map prefers actionLabel over actionGroup when both are provided', () {
      expect(
        mapper.map(
          actionLabel: GamificationLabels.hardTask,
          actionGroup: GamificationLabels.recoveryGroup,
        ),
        GamificationLabels.increaseChallenge,
      );
    });

    test('map uses actionGroup when actionLabel is absent', () {
      expect(
        mapper.map(
          actionGroup: GamificationLabels.recoveryGroup,
        ),
        GamificationLabels.provideRecovery,
      );
    });

    test('map returns maintain_challenge when both inputs are absent', () {
      expect(
        mapper.map(),
        GamificationLabels.maintainChallenge,
      );
    });

    test('mapViaActionGroup maps through derived action group', () {
      expect(
        mapper.mapViaActionGroup(GamificationLabels.rest),
        GamificationLabels.provideRecovery,
      );

      expect(
        mapper.mapViaActionGroup(GamificationLabels.motivationBoost),
        GamificationLabels.encouragePersistence,
      );
    });

    test('normalizes null or invalid action labels to maintain route', () {
      expect(
        mapper.mapActionLabelToSupportStrategy(null),
        GamificationLabels.maintainChallenge,
      );

      expect(
        mapper.mapActionLabelToSupportStrategy(''),
        GamificationLabels.maintainChallenge,
      );

      expect(
        mapper.mapActionLabelToSupportStrategy('unknown_action'),
        GamificationLabels.maintainChallenge,
      );
    });

    test('normalizes null or invalid action groups to maintain route', () {
      expect(
        mapper.mapActionGroupToSupportStrategy(null),
        GamificationLabels.maintainChallenge,
      );

      expect(
        mapper.mapActionGroupToSupportStrategy(''),
        GamificationLabels.maintainChallenge,
      );

      expect(
        mapper.mapActionGroupToSupportStrategy('unknown_group'),
        GamificationLabels.maintainChallenge,
      );
    });

    test('isRecoveryStrategy returns true only for recovery strategy', () {
      expect(
        mapper.isRecoveryStrategy(GamificationLabels.rest),
        isTrue,
      );
      expect(
        mapper.isRecoveryStrategy(GamificationLabels.easyTask),
        isFalse,
      );
    });

    test('isFlowSupportStrategy returns true only for flow support', () {
      expect(
        mapper.isFlowSupportStrategy(GamificationLabels.flowTask),
        isTrue,
      );
      expect(
        mapper.isFlowSupportStrategy(GamificationLabels.rest),
        isFalse,
      );
    });

    test('isMotivationalStrategy returns true only for motivational support', () {
      expect(
        mapper.isMotivationalStrategy(GamificationLabels.motivationBoost),
        isTrue,
      );
      expect(
        mapper.isMotivationalStrategy(GamificationLabels.hardTask),
        isFalse,
      );
    });

    test('isChallengeStrategy returns true for challenge-related actions', () {
      expect(
        mapper.isChallengeStrategy(GamificationLabels.easyTask),
        isTrue,
      );
      expect(
        mapper.isChallengeStrategy(GamificationLabels.mediumTask),
        isTrue,
      );
      expect(
        mapper.isChallengeStrategy(GamificationLabels.hardTask),
        isTrue,
      );

      expect(
        mapper.isChallengeStrategy(GamificationLabels.rest),
        isFalse,
      );
      expect(
        mapper.isChallengeStrategy(GamificationLabels.flowTask),
        isFalse,
      );
      expect(
        mapper.isChallengeStrategy(GamificationLabels.motivationBoost),
        isFalse,
      );
    });

    test('toString contains important fields', () {
      final text = mapper.toString();

      expect(text, contains('SupportStrategyMapper'));
      expect(text, contains('actionGroupMapper:'));
    });

    test('equality works for identical mappers', () {
      const a = SupportStrategyMapper();
      const b = SupportStrategyMapper();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality differs when actionGroupMapper differs', () {
      const a = SupportStrategyMapper(
        actionGroupMapper: ActionGroupMapper(),
      );
      const b = SupportStrategyMapper(
        actionGroupMapper: ActionGroupMapper(),
      );

      expect(a, equals(b));
    });
  });
}