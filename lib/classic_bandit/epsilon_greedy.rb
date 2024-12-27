# frozen_string_literal: true

module ClassicBandit
  # Implements the Epsilon-Greedy algorithm for multi-armed bandit problems.
  # This algorithm makes a random choice with probability epsilon (exploration)
  # and chooses the arm with the highest mean reward with probability 1-epsilon (exploitation).
  #
  # @example Create and use epsilon-greedy bandit
  #   arms = [
  #     ClassicBandit::Arm.new(id: 1, name: "banner_a", trials: 100, successes: 10),
  #     ClassicBandit::Arm.new(id: 2, name: "banner_b", trials: 150, successes: 14)
  #   ]
  #   bandit = ClassicBandit::EpsilonGreedy.new(arms: arms, epsilon: 0.1)
  #   selected_arm = bandit.select_arm
  #   bandit.update(selected_arm, reward: 1)
  class EpsilonGreedy
    include ArmUpdatable

    attr_reader :arms, :epsilon

    def initialize(arms:, epsilon: 0.1)
      @arms = arms
      @epsilon = epsilon

      validate_epsilon!
    end

    def select_arm
      # If no arms have been tried, do random selection
      return @arms.sample if @arms.all? { |arm| arm.trials.zero? }

      if rand < @epsilon
        # Exploration: random selection
        @arms.sample
      else
        # Exploitation: select arm with highest mean reward
        @arms.max_by(&:mean_reward)
      end
    end

    private

    def validate_epsilon!
      return if (0..1).cover?(@epsilon)

      raise ArgumentError, "epsilon must be between 0 and 1"
    end
  end
end
