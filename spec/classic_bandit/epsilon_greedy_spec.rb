# frozen_string_literal: true

RSpec.describe ClassicBandit::EpsilonGreedy do
  let(:arms) do
    [
      ClassicBandit::Arm.new(id: 1, name: "arm1"),
      ClassicBandit::Arm.new(id: 2, name: "arm2")
    ]
  end

  describe "#initialize" do
    context "with valid epsilon" do
      it "creates instance with default epsilon" do
        bandit = described_class.new(arms: arms)
        expect(bandit.epsilon).to eq(0.1)
      end

      it "creates instance with custom epsilon" do
        bandit = described_class.new(arms: arms, epsilon: 0.2)
        expect(bandit.epsilon).to eq(0.2)
      end
    end

    context "with invalid epsilon" do
      it "raises error when epsilon is negative" do
        expect { described_class.new(arms: arms, epsilon: -0.1) }
          .to raise_error(ArgumentError, "epsilon must be between 0 and 1")
      end

      it "raises error when epsilon is greater than 1" do
        expect { described_class.new(arms: arms, epsilon: 1.1) }
          .to raise_error(ArgumentError, "epsilon must be between 0 and 1")
      end
    end
  end

  describe "#select_arm" do
    let(:bandit) { described_class.new(arms: arms, epsilon: 0.5) }

    context "when no arms have been tried" do
      it "randomly selects an arm" do
        expect(arms).to receive(:sample)
        bandit.select_arm
      end
    end

    context "when exploring" do
      before do
        allow(bandit).to receive(:rand).and_return(0.1) # Ensures exploration
      end

      it "randomly selects an arm" do
        allow(arms).to receive(:sample).and_return(arms.first)
        expect(bandit.select_arm).to eq(arms.first)
      end
    end

    context "when exploiting" do
      before do
        allow(bandit).to receive(:rand).and_return(0.9) # Ensures exploitation
        arms.first.trials = 10
        arms.first.successes = 8  # 80% success rate
        arms.last.trials = 10
        arms.last.successes = 5   # 50% success rate
      end

      it "selects arm with highest mean reward" do
        expect(bandit.select_arm).to eq(arms.first)
      end
    end
  end

  describe "#update" do
    let(:bandit) { described_class.new(arms: arms) }
    let(:arm) { arms.first }

    context "with valid reward" do
      it "increments trials" do
        expect { bandit.update(arm, 1) }
          .to change { arm.trials }.by(1)
      end

      it "increments successes with reward 1" do
        expect { bandit.update(arm, 1) }
          .to change { arm.successes }.by(1)
      end

      it "does not increment successes with reward 0" do
        expect { bandit.update(arm, 0) }
          .not_to(change { arm.successes })
      end
    end

    context "with invalid reward" do
      it "raises error for non-binary reward" do
        expect { bandit.update(arm, 2) }
          .to raise_error(ArgumentError, "reward must be 0 or 1")
      end

      it "raises error for negative reward" do
        expect { bandit.update(arm, -1) }
          .to raise_error(ArgumentError, "reward must be 0 or 1")
      end
    end
  end
end
