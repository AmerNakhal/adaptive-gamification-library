def map_action_to_decision(action, state):
    eng, mot, flow, perf = state
    if action == 0:
        return {
            "difficulty_change": "decrease",
            "next_difficulty": "veryEasy",
            "reason": "Low performance",
            "pedagogical_effect": "Support learner"
        }
    elif action == 1:
        return {
            "difficulty_change": "maintain",
            "next_difficulty": "easy",
            "reason": "Moderate performance",
            "pedagogical_effect": "Stabilize learning"
        }
    elif action == 2:
        return {
            "difficulty_change": "increase",
            "next_difficulty": "medium",
            "reason": "Good performance",
            "pedagogical_effect": "Increase challenge"
        }
    elif action == 3:
        return {
            "difficulty_change": "increase",
            "next_difficulty": "hard",
            "reason": "High performance and flow",
            "pedagogical_effect": "Push learner"
        }
    else:
        return {
            "difficulty_change": "increase",
            "next_difficulty": "veryHard",
            "reason": "Excellent performance",
            "pedagogical_effect": "Maximum challenge"
        }