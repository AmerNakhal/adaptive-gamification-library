import torch
import os

def export_model(agent, path='export/trained_policy.pt'):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    torch.jit.save(torch.jit.script(agent), path)
    print(f"Model exported to {path}")
