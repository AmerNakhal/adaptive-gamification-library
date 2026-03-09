import json
import torch
import numpy as np
from export.action_mapper import map_action_to_decision

def sample_states(resolution=0.25):
    values = np.arange(0, 1 + resolution, resolution)
    states = []
    for eng in values:
        for mot in values:
            for flow in values:
                for perf in values:
                    states.append([eng, mot, flow, perf])
    return states

def safe_select_action(agent, state_tensor):
   result = agent.select_action(state_tensor)
   if isinstance(result, tuple):
        return int(result[0])
   else:
        return int(result)

def export_policy_to_json(agent, path):
    print("📤 Exporting Adaptive Educational Policy...")
    policy = []
    for state in sample_states():
        state_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
        action = safe_select_action(agent, state_tensor)
        decision = map_action_to_decision(action, state)
        policy.append({
            "state": {
                "eng": float(state[0]),
                "mot": float(state[1]),
                "flow": float(state[2]),
                "perf": float(state[3])
            },
            "action": action,
            "decision": decision
        })
    with open(path, "w") as f:
        json.dump(policy, f, indent=2)
    print(f"✅ Adaptive policy exported to {path}")

def load_policy_dict(path):
   with open(path, 'r') as f:
        policy = json.load(f)
   return policy