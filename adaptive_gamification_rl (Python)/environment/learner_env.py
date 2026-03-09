import numpy as np

class LearnerEnv:
    def __init__(self, config):
        self.num_states = config['num_states']
        self.num_actions = config['num_actions']
        self.max_steps = config.get('max_steps_per_episode', 50)

        self.current_step = 0
        self.state = None

    def reset(self):
        self.current_step = 0
        # ability, time, attention, fatigue
        self.state = np.array([0.5, 0.5, 0.5, 0.3], dtype=np.float32)
        return self.state

    def step(self, action):
        ability, time, attention, fatigue = self.state

        old_score = ability + attention - fatigue

        if action == 0:  # Rest
            fatigue -= 0.05
            attention += 0.02

        elif action == 1:  # Easy task
            ability += 0.02
            fatigue += 0.01

        elif action == 2:  # Medium task
            ability += 0.04
            attention += 0.02
            fatigue += 0.02

        elif action == 3:  # Hard task
            ability += 0.06
            fatigue += 0.04

        elif action == 4:  # Motivation boost
            attention += 0.06
            fatigue -= 0.02

        elif action == 5:  # Flow task (ideal)
            ability += 0.05
            attention += 0.05
            fatigue += 0.01


        fatigue += 0.01

        # Clip
        ability = np.clip(ability, 0.0, 1.0)
        attention = np.clip(attention, 0.0, 1.0)
        fatigue = np.clip(fatigue, 0.0, 1.0)

        new_score = ability + attention - fatigue
        reward = new_score - old_score

        self.state = np.array([ability, time, attention, fatigue], dtype=np.float32)

        self.current_step += 1
        done = self.current_step >= self.max_steps

        return self.state, reward, done
