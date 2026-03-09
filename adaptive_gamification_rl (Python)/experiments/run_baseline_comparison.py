from experiments.run_experiments import evaluate_agent, evaluate_random_policy


def run_baseline_comparison(agent, env, logger, config):
    print("🔬 Running Baseline Comparison per Episode...")

    episodes = config.get("eval_episodes", 10000)

    ppo_rewards = evaluate_agent(agent, env, episodes)
    random_rewards = evaluate_random_policy(env, episodes)

    logger.save_baseline_per_episode(ppo_rewards, random_rewards)

    logger.plot_baseline_curve(ppo_rewards, random_rewards)
