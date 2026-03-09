import numpy as np
import random
import torch

def evaluate_agent(agent, env, episodes=10000):
    rewards = []
    for _ in range(episodes):
        state = env.reset()
        total_reward = 0
        for _ in range(env.max_steps):
            state_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
            action = agent.select_action(state_tensor)
            next_state, reward, done = env.step(action)
            state = next_state
            total_reward += reward
        rewards.append(total_reward)
    return rewards

def evaluate_random_policy(env, episodes=10000):
    rewards = []
    for _ in range(episodes):
        state = env.reset()
        total_reward = 0
        for _ in range(env.max_steps):
            action = random.randint(0, env.num_actions - 1)
            next_state, reward, done = env.step(action)
            state = next_state
            total_reward += reward
        rewards.append(total_reward)
    return rewards

def run_baseline_comparison(agent, env, logger, config):
    print("🔬 Running Baseline Comparison per Episode...")
    episodes = config.get("eval_episodes", 10000)

    ppo_rewards = evaluate_agent(agent, env, episodes)
    random_rewards = evaluate_random_policy(env, episodes)

    if logger:
        logger.save_baseline_per_episode(ppo_rewards, random_rewards)
        logger.plot_baseline_curve(ppo_rewards, random_rewards)

def run_ablation_study(agent, env, logger, config):
    print("🧪 Running Ablation Study...")
    ablation_results = {}
    for action_removed in range(env.num_actions):
        state = env.reset()
        total_reward = 0
        for _ in range(env.max_steps):
            state_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
            action = agent.select_action(state_tensor)
            if action == action_removed:
                action = 0
            next_state, reward, done = env.step(action)
            state = next_state
            total_reward += reward
        ablation_results[f"Remove_Action_{action_removed}"] = total_reward

    if logger:
        logger.save_ablation_results(ablation_results)
