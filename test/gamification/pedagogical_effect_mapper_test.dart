import 'package:adaptive_gamification/src/gamification/gamification_labels.dart';
import 'package:adaptive_gamification/src/gamification/pedagogical_effect_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PedagogicalEffectMapper', () {
    const mapper = PedagogicalEffectMapper();

    test('maps rest action to recovery_support', () {
      expect(
        mapper.mapActionLabelToPedagogicalEffect(GamificationLabels.rest),
        GamificationLabels.recoverySupport,
      );
    });

    test('maps easy_task action to difficulty_reduction', () {
      expect(
        mapper.mapActionLabelToPedagogicalEffect(GamificationLabels.easyTask),
        GamificationLabels.difficultyReduction,
      );
    });

    test('maps medium_task action to difficulty_maintenance', () {
      expect(
        mapper.mapActionLabelToPedagogicalEffect(GamificationLabels.mediumTask),
        GamificationLabels.difficultyMaintenance,
      );
    });

    test('maps hard_task action to difficulty_increase', () {
      expect(
        mapper.mapActionLabelToPedagogicalEffect(GamificationLabels.hardTask),
        GamificationLabels.difficultyIncrease,
      );
    });

    test('maps motivation_boost action to motivational_reinforcement', () {
      expect(
        mapper.mapActionLabelToPedagogicalEffect(
          GamificationLabels.motivationBoost,
        ),
        GamificationLabels.motivationalReinforcement,
      );
    });

    test('maps flow_task action to flow_alignment', () {
      expect(
        mapper.mapActionLabelToPedagogicalEffect(GamificationLabels.flowTask),
        GamificationLabels.flowAlignment,
      );
    });

    test('maps reduce_pressure strategy to difficulty_reduction', () {
      expect(
        mapper.mapSupportStrategyToPedagogicalEffect(
          GamificationLabels.reducePressure,
        ),
        GamificationLabels.difficultyReduction,
      );
    });

    test('maps maintain_challenge strategy to difficulty_maintenance', () {
      expect(
        mapper.mapSupportStrategyToPedagogicalEffect(
          GamificationLabels.maintainChallenge,
        ),
        GamificationLabels.difficultyMaintenance,
      );
    });

    test('maps increase_challenge strategy to difficulty_increase', () {
      expect(
        mapper.mapSupportStrategyToPedagogicalEffect(
          GamificationLabels.increaseChallenge,
        ),
        GamificationLabels.difficultyIncrease,
      );
    });

    test('maps encourage_persistence strategy to motivational_reinforcement', () {
      expect(
        mapper.mapSupportStrategyToPedagogicalEffect(
          GamificationLabels.encouragePersistence,
        ),
        GamificationLabels.motivationalReinforcement,
      );
    });

    test('maps restore_flow strategy to flow_alignment', () {
      expect(
        mapper.mapSupportStrategyToPedagogicalEffect(
          GamificationLabels.restoreFlow,
        ),
        GamificationLabels.flowAlignment,
      );
    });

    test('maps provide_recovery strategy to recovery_support', () {
      expect(
        mapper.mapSupportStrategyToPedagogicalEffect(
          GamificationLabels.provideRecovery,
        ),
        GamificationLabels.recoverySupport,
      );
    });

    test('map prefers actionLabel over supportStrategy when both are provided', () {
      expect(
        mapper.map(
          actionLabel: GamificationLabels.hardTask,
          supportStrategy: GamificationLabels.provideRecovery,
        ),
        GamificationLabels.difficultyIncrease,
      );
    });

    test('map uses supportStrategy when actionLabel is absent', () {
      expect(
        mapper.map(
          supportStrategy: GamificationLabels.restoreFlow,
        ),
        GamificationLabels.flowAlignment,
      );
    });

    test('map returns difficulty_maintenance when both inputs are absent', () {
      expect(
        mapper.map(),
        GamificationLabels.difficultyMaintenance,
      );
    });

    test('mapViaSupportStrategy maps through derived support strategy', () {
      expect(
        mapper.mapViaSupportStrategy(GamificationLabels.rest),
        GamificationLabels.recoverySupport,
      );

      expect(
        mapper.mapViaSupportStrategy(GamificationLabels.motivationBoost),
        GamificationLabels.motivationalReinforcement,
      );

      expect(
        mapper.mapViaSupportStrategy(GamificationLabels.flowTask),
        GamificationLabels.flowAlignment,
      );
    });

    test('normalizes null or invalid action labels to maintenance effect', () {
      expect(
        mapper.mapActionLabelToPedagogicalEffect(null),
        GamificationLabels.difficultyMaintenance,
      );

      expect(
        mapper.mapActionLabelToPedagogicalEffect(''),
        GamificationLabels.difficultyMaintenance,
      );

      expect(
        mapper.mapActionLabelToPedagogicalEffect('unknown_action'),
        GamificationLabels.difficultyMaintenance,
      );
    });

    test('normalizes null or invalid support strategies to maintenance effect',
            () {
          expect(
            mapper.mapSupportStrategyToPedagogicalEffect(null),
            GamificationLabels.difficultyMaintenance,
          );

          expect(
            mapper.mapSupportStrategyToPedagogicalEffect(''),
            GamificationLabels.difficultyMaintenance,
          );

          expect(
            mapper.mapSupportStrategyToPedagogicalEffect('unknown_strategy'),
            GamificationLabels.difficultyMaintenance,
          );
        });

    test('isMotivationalEffect returns true only for motivational effect', () {
      expect(
        mapper.isMotivationalEffect(GamificationLabels.motivationBoost),
        isTrue,
      );
      expect(
        mapper.isMotivationalEffect(GamificationLabels.hardTask),
        isFalse,
      );
    });

    test('isFlowEffect returns true only for flow effect', () {
      expect(
        mapper.isFlowEffect(GamificationLabels.flowTask),
        isTrue,
      );
      expect(
        mapper.isFlowEffect(GamificationLabels.rest),
        isFalse,
      );
    });

    test('isRecoveryEffect returns true only for recovery effect', () {
      expect(
        mapper.isRecoveryEffect(GamificationLabels.rest),
        isTrue,
      );
      expect(
        mapper.isRecoveryEffect(GamificationLabels.mediumTask),
        isFalse,
      );
    });

    test('isDifficultyEffect returns true for difficulty-related actions', () {
      expect(
        mapper.isDifficultyEffect(GamificationLabels.easyTask),
        isTrue,
      );
      expect(
        mapper.isDifficultyEffect(GamificationLabels.mediumTask),
        isTrue,
      );
      expect(
        mapper.isDifficultyEffect(GamificationLabels.hardTask),
        isTrue,
      );

      expect(
        mapper.isDifficultyEffect(GamificationLabels.rest),
        isFalse,
      );
      expect(
        mapper.isDifficultyEffect(GamificationLabels.flowTask),
        isFalse,
      );
      expect(
        mapper.isDifficultyEffect(GamificationLabels.motivationBoost),
        isFalse,
      );
    });

    test('toString contains important fields', () {
      final text = mapper.toString();

      expect(text, contains('PedagogicalEffectMapper'));
      expect(text, contains('supportStrategyMapper:'));
    });

    test('equality works for identical mappers', () {
      const a = PedagogicalEffectMapper();
      const b = PedagogicalEffectMapper();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}