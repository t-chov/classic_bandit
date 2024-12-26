# frozen_string_literal: true

module ClassicBandit
  # Provides common update functionality for bandit algorithms
  # to update arm statistics with observed rewards.
  #
  # @example Update an arm with a reward
  #   class MyBandit
  #     include ArmUpdatable
  #   end
  #
  #   bandit = MyBandit.new
  #   bandit.update(selected_arm, reward: 1)
  module ArmUpdatable
    # Update the selected arm with the observed reward
    # @param arm [Arm] The arm that was selected
    # @param reward [Integer] The observed reward (0 or 1)
    def update(arm, reward)
      validate_reward!(reward)

      arm.trials += 1
      arm.successes += reward
    end

    private

    def validate_reward!(reward)
      return if [0, 1].include?(reward)

      raise ArgumentError, "reward must be 0 or 1"
    end
  end
end
