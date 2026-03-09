import numpy as np
import torch
import matplotlib.pyplot as plt
from export.export_policy_json import sample_states


class HeatmapGenerator:
    def __init__(self, agent, output_dir, resolution=0.25):
        self.agent = agent
        self.output_dir = output_dir
        self.resolution = resolution

    def _get_action_value(self, state):
        state_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
        logits, _ = self.agent(state_tensor)
        probs = torch.softmax(logits, dim=-1)
        action = torch.argmax(probs).item()
        return action

    def generate_comprehensive_heatmap(self):
        values = np.arange(0, 1 + self.resolution, self.resolution)
        heatmap = np.zeros((len(values), len(values)))

        for i, eng in enumerate(values):
            for j, mot in enumerate(values):
                actions = []
                for flow in values:
                    for perf in values:
                        state = [eng, mot, flow, perf]
                        action = self._get_action_value(state)
                        actions.append(action)
                heatmap[i, j] = np.mean(actions)

        plt.figure(figsize=(8, 6))
        plt.imshow(heatmap, origin='lower', aspect='auto')
        plt.colorbar(label="Average Selected Action")
        plt.xlabel("Motivation")
        plt.ylabel("Engagement")
        plt.title("Comprehensive Policy Heatmap")
        plt.tight_layout()
        plt.savefig(f"{self.output_dir}/comprehensive_heatmap.png")
        plt.close()

    def generate_selected_heatmaps(self):
        values = np.arange(0, 1 + self.resolution, self.resolution)
        fixed_conditions = [
            (0.2, 0.2),
            (0.8, 0.2),
            (0.2, 0.8),
            (0.8, 0.8),
            (0.5, 0.5)
        ]

        for idx, (flow, perf) in enumerate(fixed_conditions):
            heatmap = np.zeros((len(values), len(values)))

            for i, eng in enumerate(values):
                for j, mot in enumerate(values):
                    state = [eng, mot, flow, perf]
                    action = self._get_action_value(state)
                    heatmap[i, j] = action

            plt.figure(figsize=(6, 5))
            plt.imshow(heatmap, origin='lower', aspect='auto')
            plt.colorbar(label="Selected Action")
            plt.xlabel("Motivation")
            plt.ylabel("Engagement")
            plt.title(f"Selected Heatmap {idx+1} (Flow={flow}, Perf={perf})")
            plt.tight_layout()
            plt.savefig(f"{self.output_dir}/selected_heatmap_{idx+1}.png")
            plt.close()
