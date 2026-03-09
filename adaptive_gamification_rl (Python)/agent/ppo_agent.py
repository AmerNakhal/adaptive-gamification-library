import torch
import torch.nn as nn
import torch.optim as optim

class PPOAgent(nn.Module):
    def __init__(self, num_states, num_actions, lr=1e-3):
        super().__init__()
        self.num_states = num_states
        self.num_actions = num_actions

        # Actor Network
        self.actor = nn.Sequential(
            nn.Linear(num_states, 128),
            nn.ReLU(),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Linear(64, num_actions)
        )

        # Critic Network
        self.critic = nn.Sequential(
            nn.Linear(num_states, 128),
            nn.ReLU(),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Linear(64, 1)
        )

        self.optimizer = optim.Adam(self.parameters(), lr=lr)

    def forward(self, state):
        logits = self.actor(state)
        value = self.critic(state)
        return logits, value

    def select_action(self, state):
        with torch.no_grad():
            logits, _ = self(state)
            probs = torch.softmax(logits, dim=-1)
            dist = torch.distributions.Categorical(probs)
            action = dist.sample()

        return action.item()