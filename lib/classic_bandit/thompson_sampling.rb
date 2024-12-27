# frozen_string_literal: true

module ClassicBandit
  # Implements Thompson Sampling algorithm for multi-armed bandit problems.
  # Uses Beta-Bernoulli conjugate model, sampling from Beta distribution
  # using Gamma random variables.
  #
  # @example Create and use Thompson Sampling
  #   arms = [
  #     ClassicBandit::Arm.new(id: 1, name: "banner_a"),
  #     ClassicBandit::Arm.new(id: 2, name: "banner_b")
  #   ]
  #   bandit = ClassicBandit::ThompsonSampling.new(arms: arms)
  class ThompsonSampling
    include ArmUpdatable

    attr_reader :arms

    def initialize(arms:)
      @arms = arms
    end

    def select_arm
      return @arms.sample if @arms.all? { |arm| arm.trials.zero? }

      @arms.max_by { |arm| ts_score(arm) }
    end

    private

    def ts_score(arm)
      return 0.0 if arm.trials.zero?
      return 1.0 if arm.successes == arm.trials

      x = gamma_random(arm.successes + 1)
      y = gamma_random(arm.trials - arm.successes + 1)
      x / (x + y)
    end

    def gamma_random(alpha) # rubocop:disable Metrics/AbcSize
      return gamma_random(alpha + 1) * rand**(1.0 / alpha) if alpha < 1

      # Marsaglia-Tsang method
      d = alpha - 1.0 / 3
      c = 1.0 / Math.sqrt(9 * d)

      loop do
        z = normal_random
        v = (1 + c * z)**3
        u = rand

        return d * v if z > -1.0 / c && Math.log(u) < 0.5 * z * z + d * (1 - v + Math.log(v))
      end
    end

    def normal_random
      r = Math.sqrt(-2 * Math.log(rand))
      theta = 2 * Math::PI * rand
      r * Math.cos(theta)
    end
  end
end
