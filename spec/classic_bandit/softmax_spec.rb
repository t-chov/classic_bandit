# frozen_string_literal: true

RSpec.describe ClassicBandit::Softmax do
  let(:arms) do
    [
      ClassicBandit::Arm.new(id: 1, name: "arm1"),
      ClassicBandit::Arm.new(id: 2, name: "arm2")
    ]
  end

  describe "#initialize" do
    context "with valid parameters" do
      it "creates instance with valid parameters" do
        bandit = described_class.new(arms: arms, initial_temperature: 1.0, k: 0.5)
        expect(bandit.arms).to eq(arms)
      end
    end

    context "with invalid parameters" do
      it "raises error when initial_temperature is zero" do
        expect do
          described_class.new(arms: arms, initial_temperature: 0, k: 0.5)
        end.to raise_error(ArgumentError, "initial_temperature must be positive")
      end

      it "raises error when initial_temperature is negative" do
        expect do
          described_class.new(arms: arms, initial_temperature: -1.0, k: 0.5)
        end.to raise_error(ArgumentError, "initial_temperature must be positive")
      end

      it "raises error when k is zero" do
        expect do
          described_class.new(arms: arms, initial_temperature: 1.0, k: 0)
        end.to raise_error(ArgumentError, "k must be positive")
      end

      it "raises error when k is negative" do
        expect do
          described_class.new(arms: arms, initial_temperature: 1.0, k: -0.5)
        end.to raise_error(ArgumentError, "k must be positive")
      end
    end
  end

  describe "#select_arm" do
    let(:bandit) { described_class.new(arms: arms, initial_temperature: 1.0, k: 0.5) }

    context "when no arms have been tried" do
      it "randomly selects an arm" do
        expect(arms).to receive(:sample)
        bandit.select_arm
      end
    end

    context "when arms have different rewards" do
      before do
        # arm1: 高い報酬率
        arms.first.trials = 10
        arms.first.successes = 8 # 80% success

        # arm2: 低い報酬率
        arms.last.trials = 10
        arms.last.successes = 2 # 20% success
      end

      it "tends to select arm with higher reward" do
        # 統計的な性質をテストするため、複数回試行
        selections = 1000.times.map { bandit.select_arm }
        arm1_count = selections.count(arms.first)
        arm2_count = selections.count(arms.last)

        # 報酬の高いarm1の方が多く選ばれるはず
        expect(arm1_count).to be > arm2_count
      end
    end

    context "with temperature decay" do
      let(:bandit) { described_class.new(arms: arms, initial_temperature: 1.0, k: 0.1) }

      before do
        arms.first.trials = 1000
        arms.first.successes = 80 # 8% success
        arms.last.trials = 1000
        arms.last.successes = 20  # 2% success
      end

      it "becomes more exploitative over time" do
        selections = 1000.times.map { bandit.select_arm }
        arm1_count = selections.count(arms.first)

        expect(arm1_count).to be > 500
      end
    end
  end
end
