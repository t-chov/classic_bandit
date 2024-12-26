# ClassicBandit

[![CI](https://github.com/t-chov/classic_bandit/actions/workflows/ci.yml/badge.svg)](https://github.com/t-chov/classic_bandit/actions/workflows/ci.yml)

A Ruby library for classic (non-contextual) multi-armed bandit algorithms including Thompson Sampling, UCB1, and Epsilon-Greedy.

## Requirements

- Ruby >= 3.0.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'classic_bandit'
```

And then execute:

``bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install classic_bandit
```

## Usage

### A/B Testing Example

```ruby
require 'classic_bandit'

# Initialize banners for A/B testing
arms = [
  ClassicBandit::Arm.new(id: 'banner_a', name: 'Spring Campaign'),
  ClassicBandit::Arm.new(id: 'banner_b', name: 'Summer Campaign')
]

# Choose algorithm: Epsilon-Greedy with 10% exploration
bandit = ClassicBandit::EpsilonGreedy.new(arms: arms, epsilon: 0.1)

# In your application
selected_arm = bandit.select_arm
# Display the selected banner to user
show_banner(selected_arm.id)

# Update with user's response
# 1 for click, 0 for no click
bandit.update(selected_arm, reward: 1)
```

## Available Algorithms

### Epsilon-Greedy

Balances exploration and exploitation with a fixed exploration rate.

```ruby
bandit = ClassicBandit::EpsilonGreedy.new(arms: arms, epsilon: 0.1)
```

- Simple
- Explicitly controls exploration with ε parameter
- Explores randomly with probability ε, exploits best arm with probability 1-ε

### UCB1

Upper Confidence Bound algorithm that automatically balances exploration and exploitation.

```ruby
bandit = ClassicBandit::Ucb1.new(arms: arms)
```

- No explicit exploration parameter needed
- Automatically balances exploration and exploitation
- Uses confidence bounds to select arms
- Always tries untested arms first

### Common Interface
All algorithms share the same interface:

```ruby
# Select an arm
arm = bandit.select_arm

# Update the arm with reward
bandit.update(arm, reward: 1)  # Success
bandit.update(arm, reward: 0)  # Failure
```

## Development

After checking out the repo, run:
```bash
$ bundle install
$ bundle exec rspec
```

To release a new version:

1. Update the version number in version.rb
2. Create a git tag for the version
3. Push git commits and tags

### License

The gem is available as open source under the terms of the MIT License.