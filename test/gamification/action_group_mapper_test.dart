import 'package:adaptive_gamification/src/gamification/action_group_mapper.dart';
import 'package:adaptive_gamification/src/gamification/gamification_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActionGroupMapper', () {
    const mapper = ActionGroupMapper();

    test('maps rest to recovery group', () {
      expect(
        mapper.mapActionLabelToGroup(GamificationLabels.rest),
        GamificationLabels.recoveryGroup,
      );
    });

    test('maps easy_task to challenge adjustment group', () {
      expect(
        mapper.mapActionLabelToGroup(GamificationLabels.easyTask),
        GamificationLabels.challengeAdjustmentGroup,
      );
    });

    test('maps medium_task to challenge adjustment group', () {
      expect(
        mapper.mapActionLabelToGroup(GamificationLabels.mediumTask),
        GamificationLabels.challengeAdjustmentGroup,
      );
    });

    test('maps hard_task to challenge adjustment group', () {
      expect(
        mapper.mapActionLabelToGroup(GamificationLabels.hardTask),
        GamificationLabels.challengeAdjustmentGroup,
      );
    });

    test('maps motivation_boost to motivational support group', () {
      expect(
        mapper.mapActionLabelToGroup(GamificationLabels.motivationBoost),
        GamificationLabels.motivationalSupportGroup,
      );
    });

    test('maps flow_task to flow regulation group', () {
      expect(
        mapper.mapActionLabelToGroup(GamificationLabels.flowTask),
        GamificationLabels.flowRegulationGroup,
      );
    });

    test('normalizes null action label to default medium_task group', () {
      expect(
        mapper.mapActionLabelToGroup(null),
        GamificationLabels.challengeAdjustmentGroup,
      );
    });

    test('normalizes empty action label to default medium_task group', () {
      expect(
        mapper.mapActionLabelToGroup('   '),
        GamificationLabels.challengeAdjustmentGroup,
      );
    });

    test('normalizes unsupported action label to default group', () {
      expect(
        mapper.mapActionLabelToGroup('unknown_action'),
        GamificationLabels.challengeAdjustmentGroup,
      );
    });

    test('isRecoveryAction returns true only for recovery group actions', () {
      expect(
        mapper.isRecoveryAction(GamificationLabels.rest),
        isTrue,
      );
      expect(
        mapper.isRecoveryAction(GamificationLabels.easyTask),
        isFalse,
      );
      expect(
        mapper.isRecoveryAction(GamificationLabels.motivationBoost),
        isFalse,
      );
    });

    test('isChallengeAdjustmentAction returns true for challenge actions', () {
      expect(
        mapper.isChallengeAdjustmentAction(GamificationLabels.easyTask),
        isTrue,
      );
      expect(
        mapper.isChallengeAdjustmentAction(GamificationLabels.mediumTask),
        isTrue,
      );
      expect(
        mapper.isChallengeAdjustmentAction(GamificationLabels.hardTask),
        isTrue,
      );

      expect(
        mapper.isChallengeAdjustmentAction(GamificationLabels.rest),
        isFalse,
      );
      expect(
        mapper.isChallengeAdjustmentAction(GamificationLabels.flowTask),
        isFalse,
      );
    });

    test('isMotivationalSupportAction returns true only for motivational action',
            () {
          expect(
            mapper.isMotivationalSupportAction(GamificationLabels.motivationBoost),
            isTrue,
          );
          expect(
            mapper.isMotivationalSupportAction(GamificationLabels.easyTask),
            isFalse,
          );
        });

    test('isFlowRegulationAction returns true only for flow action', () {
      expect(
        mapper.isFlowRegulationAction(GamificationLabels.flowTask),
        isTrue,
      );
      expect(
        mapper.isFlowRegulationAction(GamificationLabels.rest),
        isFalse,
      );
    });

    test('toString returns readable type name', () {
      expect(
        mapper.toString(),
        contains('ActionGroupMapper'),
      );
    });

    test('equality works for identical stateless mappers', () {
      const a = ActionGroupMapper();
      const b = ActionGroupMapper();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}