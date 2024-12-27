# frozen_string_literal: true

module ClassicBandit
  # Represents an arm in a multi-armed bandit problem.
  # Each arm maintains its own trial counts and success counts,
  # which are used by various bandit algorithms to make decisions.
  #
  # @example Create a new arm
  #   arm = ClassicBandit::Arm.new(id: 1, name: "banner_a")
  #   arm.trials  #=> 0
  #   arm.successes #=> 0
  class Arm
    attr_reader :id, :name
    attr_accessor :trials, :successes

    def initialize(id:, name: nil, trials: 0, successes: 0)
      @id = id
      @name = name || id.to_s
      @trials = trials
      @successes = successes
    end

    # Calculate mean reward (success rate) for this arm
    # @return [Float] Mean reward (0.0 if no trials)
    def mean_reward
      return 0.0 if @trials.zero?

      @successes.to_f / @trials
    end
  end
end
