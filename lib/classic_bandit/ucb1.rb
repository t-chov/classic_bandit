# frozen_string_literal: true

module ClassicBandit
  # Implements the UCB1 (Upper Confidence Bound) algorithm for multi-armed bandit problems.
  # This algorithm selects arms based on their mean rewards plus a confidence term,
  # balancing exploration and exploitation without requiring an explicit epsilon parameter.
  #
  # @example Create and use UCB1 bandit
  #   arms = [
  #     ClassicBandit::Arm.new(id: 1, name: "banner_a"),
  #     ClassicBandit::Arm.new(id: 2, name: "banner_b")
  #   ]
  #   bandit = ClassicBandit::Ucb1.new(arms: arms)
  #   selected_arm = bandit.select_arm
  #   bandit.update(selected_arm, reward: 1)
  class Ucb1
    include ArmUpdatable

    # @return [Array<Arm>] Available arms for selection
    attr_reader :arms

    # Initialize a new UCB1 bandit
    # @param arms [Array<Arm>] List of arms to choose from
    def initialize(arms:)
      @arms = arms
    end

    # Select an arm using the UCB1 algorithm.
    # Initially tries each arm once, then uses UCB1 formula for selection.
    # @return [Arm] Selected arm
    def select_arm
      # use untried arm if exists.
      untried_arm = @arms.find { |arm| arm.trials.zero? }
      return untried_arm if untried_arm

      total_trials = @arms.sum(&:trials)
      @arms.max_by { |arm| ucb_score(arm, total_trials) }
    end

    private

    def ucb_score(arm, total_trials)
      return Float::INFINITY if arm.trials.zero?

      mean_reward = arm.successes.to_f / arm.trials
      exploration_term = Math.sqrt(2 * Math.log(total_trials) / arm.trials)

      mean_reward + exploration_term
    end
  end
end
