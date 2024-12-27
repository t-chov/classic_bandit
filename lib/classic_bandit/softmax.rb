# frozen_string_literal: true

module ClassicBandit
  # Implements the Softmax algorithm for multi-armed bandit problems.
  # This algorithm selects arms based on Boltzmann distribution,
  # with temperature parameter controlling exploration-exploitation balance.
  #
  # @example Create and use Softmax bandit
  #   arms = [
  #     ClassicBandit::Arm.new(id: 1, name: "banner_a"),
  #     ClassicBandit::Arm.new(id: 2, name: "banner_b")
  #   ]
  #   bandit = ClassicBandit::Softmax.new(
  #     arms: arms,
  #     initial_temperature: 1.0,
  #     k: 0.5
  #   )
  class Softmax
    include ArmUpdatable

    attr_reader :arms

    def initialize(arms:, initial_temperature:, k:) # rubocop:disable Naming/MethodParameterName
      @arms = arms
      @initial_temperature = initial_temperature
      @k = k

      validate_parameters!
    end

    def select_arm
      return @arms.sample if @arms.all? { |arm| arm.trials.zero? }

      probabilities = @arms.map { |arm| softmax_score(arm, temperature) }
      cumulative_prob = 0
      random_value = rand

      @arms.each_with_index do |arm, i|
        cumulative_prob += probabilities[i]
        return arm if random_value <= cumulative_prob
      end

      @arms.last
    end

    private

    def softmax_score(arm, temperature)
      exp_values = @arms.map { |a| Math.exp(a.mean_reward / temperature) }
      Math.exp(arm.mean_reward / temperature) / exp_values.sum
    end

    def temperature
      total_trials = @arms.sum(&:trials)
      @initial_temperature / Math.log(@k * total_trials + 2)
    end

    def validate_parameters!
      raise ArgumentError, "initial_temperature must be positive" unless @initial_temperature.positive?
      raise ArgumentError, "k must be positive" unless @k.positive?
    end
  end
end
