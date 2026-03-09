import os
import yaml
from environment.learner_env import LearnerEnv
from agent.ppo_agent import PPOAgent
from training.train import train_agent
from logger.telemetry import Logger
from logger.heatmap_generator import HeatmapGenerator
from export.export_model import export_model
from export.export_policy_json import export_policy_to_json
from experiments.run_experiments import (
    run_baseline_comparison,
    run_ablation_study
)
from utils.helpers import set_seed

with open('configs/config.yaml') as f:
    config = yaml.safe_load(f)

os.makedirs('results', exist_ok=True)
os.makedirs('export', exist_ok=True)

seeds = [0, 1, 2, 3, 4]

for seed in seeds:
    print(f"\n🔹 Running experiment with seed = {seed}")
    set_seed(seed)

    env = LearnerEnv(config)

    agent = PPOAgent(
        num_states=config['num_states'],
        num_actions=config['num_actions'],
        lr=config['lr']
    )

    logger = Logger(
        output_dir=f"results/seed_{seed}",
        num_actions=config['num_actions']
    )

    train_agent(agent, env, config, logger)

    logger.export_csv()
    logger.plot_reward_curve()
    logger.plot_state_trajectories()
    logger.plot_action_distribution()

    run_baseline_comparison(agent, env, logger, config)
    run_ablation_study(agent, env, logger, config)

    print("🔥 Generating Heatmaps...")
    heatmap_gen = HeatmapGenerator(
        agent=agent,
        output_dir=logger.output_dir,
        resolution=0.1
    )
    heatmap_gen.generate_comprehensive_heatmap()
    heatmap_gen.generate_selected_heatmaps()

    export_model(agent, f"export/trained_policy_seed_{seed}.pt")
    export_policy_to_json(agent, f"export/adaptive_policy_seed_{seed}.json")

    print(f"✅ Results for seed {seed} saved successfully.")


print("\n🎉 All experiments completed successfully.")
