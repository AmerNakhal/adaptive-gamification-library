# Reinforcement Learning Engine

This module contains the Reinforcement Learning system responsible for training the adaptive policy used in the educational application.

The goal of the RL system is to learn an optimal strategy for selecting task difficulty levels based on the learner's current state.

The trained policy is later exported and used by the Flutter application to dynamically adapt the learning experience.

---

## System Overview

The reinforcement learning engine simulates a learner interacting with an educational system.  
Based on the learner's state, the agent decides the most appropriate difficulty level for the next learning task.

The training process aims to maximize long-term learning performance while maintaining learner engagement and motivation.

---

## Reinforcement Learning Method

The system uses the following RL algorithm:

**Proximal Policy Optimization (PPO)**

PPO is a policy gradient method known for:

- stability
- efficiency
- good performance in continuous environments

The agent learns a policy that maps learner states to difficulty-selection actions.

---

## State Representation

The learner state is represented by four normalized variables:
[ ability, time, attention, fatigue ]
Each value ranges between:

0.0 - 1.0

These variables simulate the cognitive and behavioral state of a learner.

---

## Action Space

The agent can choose one of several learning actions:

0 → Rest 

1 → Easy Task 

2 → Medium Task

3 → Hard Task

4 → Motivation Boost

5 → Flow Task

Each action affects the learner state differently.

---

## Reward Function Design

The reward function is designed to encourage:

- improvement in learner ability
- sustained engagement
- balanced cognitive load

The agent receives positive rewards when:

- learner ability increases
- learner engagement remains stable
- fatigue remains within acceptable limits

Negative rewards are given when:

- fatigue becomes too high
- attention drops significantly
- learning performance deteriorates

---

## Training Environment Details

The learner environment simulates how a student responds to different task difficulties.

The environment is implemented in: environment/learner_env.py

This environment models how actions influence:

- ability
- attention
- fatigue
- learning progress

---

## Neural Network Architecture

The PPO agent consists of two neural networks:

### Actor Network

The actor network outputs the probability distribution over possible actions.

Input: state vector (4 values)

Output: action probabilities

---

### Critic Network

The critic network estimates the value of the current state.

Input: state vector

Output: state value estimate

---

## Training Pipeline

The training process includes the following steps:

1. Initialize the environment
2. Initialize the PPO agent
3. Run simulation episodes
4. Collect state-action-reward trajectories
5. Compute advantages
6. Update actor and critic networks
7. Repeat training for multiple episodes

The training loop is implemented in: training/train.py

---

## Experiments Overview

The project includes several experiments used to evaluate the system.

### Baseline Comparison

The adaptive RL policy is compared with a random action policy.

File: experiments/run_baseline_comparison.py

Purpose:

- evaluate whether the RL policy performs better than random difficulty selection

---

### Ablation Study

An ablation study is used to analyze the importance of different system components.

File: experiments/run_ablation_study.py

Purpose:

- evaluate the impact of removing certain model features.

---

### Standard Experiment Run

Main experiment execution: experiments/run_experiments.py

This script runs multiple training sessions and collects performance statistics.

---

## Telemetry and Logging System

Training metrics are recorded during the training process.

Logged data includes:

- rewards
- action distribution
- learner state trajectories

The telemetry system is implemented in: logger/telemetry.py

Training logs are saved as: training_log.csv  
These files are saved in the output directory specified in the configuration file (default: `results/seed_X/`).

All CSV files and generated heatmaps are stored within this output directory.

---

## Visualization Tools

The project generates visualizations for analyzing the learned policy.

These include:

- reward curves
- action frequency charts
- policy heatmaps

Heatmaps are generated using: logger/heatmap_generator.py  
Generated heatmaps are saved in the same output directory.

---

## Exporting the Trained Policy

After training, the model can be exported in two formats.

### PyTorch Model
trained_policy.pt

Exported using: export/export_model.py

---

### JSON Policy Table

adaptive_policy.json

Exported using: export/export_policy_json.py

This JSON file is used by the Flutter application to perform real-time difficulty adaptation.

---

## API Server Interface

An API server is included to allow external applications to query the trained model.

Implemented using:

FastAPI

File: api_server.py

Example endpoint: POST /get_action

Input: learner state

Output: recommended action

---

## Running the Training

Example training command: python training/train.py

Running experiments: python experiments/run_experiments.py

Running baseline comparison: python experiments/run_baseline_comparison.py

---

## Demo / Quick Examples

For a quick verification of the system functionality, you can run a short example session:

```bash
python main.py
```

This command runs a brief training session using the default configuration and seeds, allowing you to quickly check that the system is working as expected.

---

## Setup Instructions

Install required packages:

```bash
pip install -r requirements.txt
```

### Quick Test

For a quick verification of the system:

```bash
python main.py
```

This runs a short training session using the default configuration and seeds.

---

## Project Structure
adaptive_gamification_rl/

agent/
- ppo_agent.py

api/
- api_server.py

configs/
- config.yaml

environment/
- learner_env.py

experiments/
- run_ablation_study.py
- run_baseline_comparison.py
- run_experiments.py

export/
- action_mapper.py
- export_model.py
- export_policy_json.py

logger/
- heatmap_generator.py
- telemetry.py

training/
- train.py

utils/ 
- helpers.py

main.py

---

## Integration with Flutter Application

The trained policy is exported as: adaptive_policy.json

This file is loaded by the Flutter application and used to determine the next difficulty level during quiz sessions.

The mobile application then dynamically adapts the learning experience based on learner performance.

---

## Research Goal

The goal of this system is to explore how reinforcement learning can be used to support adaptive educational systems.

The trained agent learns how to balance:

- challenge
- engagement
- learner ability

to provide a personalized learning experience.

---

## Demonstration Materials

A `demo/` folder is included in the repository, containing output files generated by the Python Reinforcement Learning system.

### CSV Files
- `demo/csv/training_log.csv` — Detailed log of all steps, actions, and rewards per episode
- `demo/csv/baseline_per_episode.csv` — Comparison of PPO agent vs random policy for each episode
- `demo/csv/ablation.csv` — Results of ablation studies analyzing system components

### PNG Visualizations
- `demo/python_results/action_distribution.png` — Frequency of actions taken by the agent
- `demo/python_results/baseline_comparison_curve.png` — Reward comparison curve showing PPO agent vs random policy across episodes
- `demo/python_results/comprehensive_heatmap.png` — Heatmap of policy decisions over the full state space
- `demo/python_results/reward_curve.png` — Total reward per episode
- `demo/python_results/selected_heatmap_1.png` — Example selected heatmap 1
- `demo/python_results/selected_heatmap_2.png` — Example selected heatmap 2
- `demo/python_results/state_trajectories.png` — Trajectories of learner states over time
