import os
import csv
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

class Logger:
    def __init__(self, output_dir='results/seed_0', num_actions=6, num_selected_heatmaps=5):
        self.output_dir = output_dir
        os.makedirs(self.output_dir, exist_ok=True)

        self.episodes = []
        self.steps = []
        self.states = []
        self.actions = []
        self.rewards = []

        self.num_actions = num_actions
        self.num_selected_heatmaps = num_selected_heatmaps

    def log_step(self, episode, step, state, action, reward):
        self.episodes.append(episode)
        self.steps.append(step)
        self.states.append(list(state))
        self.actions.append(int(action))
        self.rewards.append(float(reward))

    def export_csv(self):
        path = os.path.join(self.output_dir, "training_log.csv")
        with open(path, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["episode","step","s1","s2","s3","s4","action","reward"])
            for ep, st, s, a, r in zip(self.episodes, self.steps, self.states, self.actions, self.rewards):
                writer.writerow([ep, st, *s, a, r])
        print(f"✅ Training CSV exported to {path}")

    def plot_reward_curve(self):
        rewards_per_episode = defaultdict(float)
        for ep, r in zip(self.episodes, self.rewards):
            rewards_per_episode[ep] += r
        plt.figure()
        plt.plot(list(rewards_per_episode.keys()), list(rewards_per_episode.values()))
        plt.xlabel("Episode")
        plt.ylabel("Total Reward")
        plt.title("Reward Curve")
        plt.savefig(os.path.join(self.output_dir, "reward_curve.png"))
        plt.close()
        print("✅ Reward curve saved")

    def plot_state_trajectories(self):
        if not self.states:
            return
        arr = np.array(self.states)
        plt.figure()
        for i in range(arr.shape[1]):
            plt.plot(arr[:, i], label=f"state_{i+1}")
        plt.legend()
        plt.title("State Trajectories")
        plt.savefig(os.path.join(self.output_dir, "state_trajectories.png"))
        plt.close()
        print("✅ State trajectories saved")

    def plot_action_distribution(self):
        if not self.actions:
            return
        counts = defaultdict(int)
        for a in self.actions:
            counts[a] += 1
        plt.figure()
        plt.bar(list(counts.keys()), list(counts.values()))
        plt.xlabel("Action")
        plt.ylabel("Frequency")
        plt.title("Action Distribution")
        plt.savefig(os.path.join(self.output_dir, "action_distribution.png"))
        plt.close()
        print("✅ Action distribution saved")

    def save_baseline_per_episode(self, ppo_rewards, random_rewards):
        path = os.path.join(self.output_dir, "baseline_per_episode.csv")
        with open(path, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["Episode", "PPO", "Random"])
            for i, (p, r) in enumerate(zip(ppo_rewards, random_rewards)):
                writer.writerow([i + 1, p, r])
        print(f"✅ Baseline per-episode CSV saved to {path}")

    def plot_baseline_curve(self, ppo_rewards, random_rewards):
        plt.figure(figsize=(10,5))
        plt.plot(range(1, len(ppo_rewards)+1), ppo_rewards, label="PPO", color="blue")
        plt.plot(range(1, len(random_rewards)+1), random_rewards, label="Random", color="orange")
        plt.xlabel("Episode")
        plt.ylabel("Total Reward")
        plt.title("Baseline Comparison per Episode")
        plt.legend()
        plt.tight_layout()
        plt.savefig(os.path.join(self.output_dir, "baseline_comparison_curve.png"))
        plt.close()
        print("✅ Baseline comparison curve saved")

    def save_ablation_results(self, ablation_dict):
        path = os.path.join(self.output_dir, "ablation.csv")
        with open(path, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["removed_component","reward"])
            for k, v in ablation_dict.items():
                writer.writerow([k, v])
        print(f"✅ Ablation results saved to {path}")

    def plot_comprehensive_heatmap(self):
        if not self.states:
            return
        arr = np.array(self.states)
        heatmap = np.mean(arr, axis=0, keepdims=True)
        plt.figure()
        plt.imshow(heatmap.repeat(len(arr), axis=0), cmap='hot', interpolation='nearest')
        plt.colorbar()
        plt.title("Comprehensive Heatmap")
        plt.savefig(os.path.join(self.output_dir, "comprehensive_heatmap.png"))
        plt.close()
        print("✅ Comprehensive heatmap saved")

    def plot_selected_heatmaps(self, num=5):
        if not self.states:
            return
        arr = np.array(self.states)
        indices = np.linspace(0, len(arr)-1, num, dtype=int)
        for i, idx in enumerate(indices):
            heatmap = arr[idx:idx+1,:]
            plt.figure()
            plt.imshow(heatmap.repeat(10, axis=0), cmap='hot', interpolation='nearest')
            plt.colorbar()
            plt.title(f"Selected Heatmap {i+1}")
            plt.savefig(os.path.join(self.output_dir, f"selected_heatmap_{i+1}.png"))
            plt.close()
        print("✅ Selected heatmaps saved")
