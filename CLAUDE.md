# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- **Run tests**: `bundle exec rspec`
- **Lint code**: `bundle exec rubocop`
- **Run all checks**: `bundle exec rake` (runs both tests and linting)
- **Install dependencies**: `bundle install`

The project uses RuboCop for linting with explicit config file reference in Rakefile:15.

## Architecture Overview

ClassicBandit is a Ruby gem implementing multi-armed bandit algorithms for A/B testing and optimization. The library uses Zeitwerk for autoloading and follows a modular design pattern.

### Core Components

**Arm (`lib/classic_bandit/arm.rb`)**: Represents a bandit arm with trial/success tracking and mean reward calculation.

**ArmUpdatable (`lib/classic_bandit/arm_updatable.rb`)**: Shared module providing `update(arm, reward)` method for all bandit algorithms. Validates rewards are 0 or 1.

**Algorithm Implementations**:
- **EpsilonGreedy**: Simple ε-greedy with exploration/exploitation balance
- **UCB1**: Upper Confidence Bound without explicit parameters  
- **Softmax**: Temperature-based Boltzmann distribution selection
- **ThompsonSampling**: Bayesian approach with Beta-Bernoulli model using custom Gamma random number generation

### Key Design Patterns

All algorithms implement the same interface:
- `select_arm()` → returns an Arm instance
- `update(arm, reward)` → updates arm statistics (from ArmUpdatable)
- Handle untested arms by random selection

The Thompson Sampling implementation includes custom statistical functions (`gamma_random`, `normal_random`) using Marsaglia-Tsang method for Gamma distribution sampling.

### Testing Structure

Tests are organized in `spec/` with individual algorithm specs and a main gem spec. Uses standard RSpec testing framework.

### Example Usage

The `example/` directory contains simulation scripts demonstrating algorithm comparison with Gnuplot visualization, showing realistic usage patterns with pre-populated arm statistics.