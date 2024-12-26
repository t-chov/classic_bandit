# frozen_string_literal: true

RSpec.describe ClassicBandit::Ucb1 do
  let(:arms) do
    [
      ClassicBandit::Arm.new(id: 1, name: "arm1"),
      ClassicBandit::Arm.new(id: 2, name: "arm2")
    ]
  end

  describe "#initialize" do
    it "creates instance with arms" do
      bandit = described_class.new(arms: arms)
      expect(bandit.arms).to eq(arms)
    end
  end

  describe "#select_arm" do
    let(:bandit) { described_class.new(arms: arms) }

    context "when no arms have been tried" do
      it "selects first untried arm" do
        expect(bandit.select_arm).to eq(arms.first)
      end
    end

    context "when some arms are untried" do
      before do
        arms.first.trials = 5
        arms.first.successes = 3
      end

      it "selects untried arm" do
        expect(bandit.select_arm).to eq(arms.last)
      end
    end

    context "when all arms have been tried" do
      before do
        # arm1: mean=0.6, trials=5
        arms.first.trials = 5
        arms.first.successes = 3

        # arm2: mean=0.4, trials=10
        arms.last.trials = 10
        arms.last.successes = 4
      end

      it "selects arm with highest UCB score" do
        expect(bandit.select_arm).to eq(arms.first)
      end
    end
  end

  describe "UCB score calculation" do
    let(:bandit) { described_class.new(arms: arms) }

    context "when comparing arms with different trial counts" do
      before do
        arms.first.trials = 100
        arms.first.successes = 80 # 80% success

        arms.last.trials = 10
        arms.last.successes = 6 # 60% success
      end

      it "balances exploration and exploitation" do
        expect(bandit.select_arm).to eq(arms.last)
      end
    end
  end
end
