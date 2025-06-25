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

    attr_reader :arms, :alpha_prior, :beta_prior

    # @param arms [Array<Arm>] Array of arms to choose from
    # @param alpha_prior [Float] Prior parameter for successes (default: 1.0)
    # @param beta_prior [Float] Prior parameter for failures (default: 1.0)
    def initialize(arms:, alpha_prior: 1.0, beta_prior: 1.0)
      @arms = arms
      @alpha_prior = alpha_prior
      @beta_prior = beta_prior
    end

    def select_arm
      @arms.max_by { |arm| ts_score(arm) }
    end

    private

    def ts_score(arm)
      alpha = arm.successes + @alpha_prior
      beta = (arm.trials - arm.successes) + @beta_prior
      
      beta_sample(alpha, beta)
    end

    def beta_sample(alpha, beta)
      # Beta(1,1) = Uniform(0,1)
      return rand if alpha == 1.0 && beta == 1.0
      
      x = gamma_random(alpha)
      y = gamma_random(beta)
      x / (x + y)
    end

    def gamma_random(alpha) # rubocop:disable Metrics/AbcSize
      return gamma_random(alpha + 1) * rand**(1.0 / alpha) if alpha < 1
    
      # Marsaglia-Tsang method
      d = alpha - 1.0 / 3
      c = 1.0 / Math.sqrt(9 * d)
    
      loop do
        x = normal_random
        v = (1 + c * x)**3
        
        next if v <= 0
        
        u = rand
        
        # Squeeze test
        return d * v if u < 1 - 0.0331 * x**4
        
        # Full test
        return d * v if Math.log(u) < 0.5 * x * x + d - d * v + d * Math.log(v)
      end
    end

    def normal_random
      r = Math.sqrt(-2 * Math.log(rand))
      theta = 2 * Math::PI * rand
      r * Math.cos(theta)
    end
  end
end
