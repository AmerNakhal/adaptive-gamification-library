import torch
import torch.nn as nn
import torch.nn.functional as F

def train_agent(agent, env, config, logger=None):
    num_episodes = config.get('episodes', 10000)
    gamma = config.get('gamma', 0.99)
    gae_lambda = config.get('gae_lambda', 0.95)
    clip_epsilon = config.get('clip_epsilon', 0.2)
    update_epochs = config.get('update_epochs', 10)
    batch_size = config.get('batch_size', 64)
    entropy_coef = config.get('entropy_coef', 0.01)
    value_loss_coef = config.get('value_loss_coef', 0.5)
    max_grad_norm = config.get('max_grad_norm', 0.5)

    optimizer = agent.optimizer

    for episode in range(num_episodes):
        states = []
        actions = []
        rewards = []
        log_probs = []
        values = []
        state = env.reset()
        for step in range(env.max_steps):
            state_tensor = torch.tensor(state, dtype=torch.float32).unsqueeze(0)
            logits, value = agent(state_tensor)
            probs = F.softmax(logits, dim=-1)
            dist = torch.distributions.Categorical(probs)
            action = dist.sample()
            next_state, reward, done = env.step(action.item())
            states.append(state_tensor)
            actions.append(action)
            rewards.append(reward)
            log_probs.append(dist.log_prob(action))
            values.append(value)
            if logger:
                logger.log_step(episode=episode, step=step, state=state, action=action.item(), reward=reward)
            state = next_state
            if done:
                break

        values = torch.cat(values).squeeze(-1)
        log_probs = torch.stack(log_probs)
        returns = []
        advantages = []
        R = 0
        adv = 0
        for r, v in zip(reversed(rewards), reversed(values.detach().numpy())):
            R = r + gamma * R
            delta = r + gamma * v - v
            adv = delta + gamma * gae_lambda * adv
            returns.insert(0, R)
            advantages.insert(0, adv)

        returns = torch.tensor(returns, dtype=torch.float32)
        advantages = torch.tensor(advantages, dtype=torch.float32)
        advantages = (advantages - advantages.mean()) / (advantages.std() + 1e-8)
        states_tensor = torch.cat(states)
        actions_tensor = torch.tensor([a.item() for a in actions])
        old_log_probs = log_probs.detach()
        for _ in range(update_epochs):
            logits, values_pred = agent(states_tensor)
            values_pred = values_pred.squeeze(-1)
            probs = F.softmax(logits, dim=-1)
            dist = torch.distributions.Categorical(probs)
            log_probs_new = dist.log_prob(actions_tensor)
            entropy = dist.entropy().mean()
            ratio = torch.exp(log_probs_new - old_log_probs)
            surr1 = ratio * advantages
            surr2 = torch.clamp(ratio, 1.0 - clip_epsilon, 1.0 + clip_epsilon) * advantages
            policy_loss = -torch.min(surr1, surr2).mean()
            value_loss = F.mse_loss(values_pred, returns)
            loss = policy_loss + value_loss_coef * value_loss - entropy_coef * entropy
            optimizer.zero_grad()
            loss.backward()
            nn.utils.clip_grad_norm_(agent.parameters(), max_grad_norm)
            optimizer.step()

        if episode % max(1, num_episodes // 100) == 0:
            total_reward = sum(rewards)
            print(f"Episode {episode} | Reward: {total_reward:.3f} | Loss: {loss.item():.3f}")

    return agent, env