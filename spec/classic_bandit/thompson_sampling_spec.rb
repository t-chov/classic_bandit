# frozen_string_literal: true

RSpec.describe ClassicBandit::ThompsonSampling do
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

    it "creates instance with custom priors" do
      bandit = described_class.new(arms: arms, alpha_prior: 2.0, beta_prior: 3.0)
      expect(bandit.alpha_prior).to eq(2.0)
      expect(bandit.beta_prior).to eq(3.0)
    end

    it "validates alpha_prior parameter" do
      expect do
        described_class.new(arms: arms, alpha_prior: -1.0)
      end.to raise_error(ArgumentError, "alpha_prior must be positive")
      expect do
        described_class.new(arms: arms, alpha_prior: 0)
      end.to raise_error(ArgumentError, "alpha_prior must be positive")
    end

    it "validates beta_prior parameter" do
      expect do
        described_class.new(arms: arms, beta_prior: -1.0)
      end.to raise_error(ArgumentError, "beta_prior must be positive")
      expect do
        described_class.new(arms: arms, beta_prior: 0)
      end.to raise_error(ArgumentError, "beta_prior must be positive")
    end
  end

  describe "#select_arm" do
    let(:bandit) { described_class.new(arms: arms) }

    context "when no arms have been tried" do
      it "randomly selects an arm" do
        expect(arms).to receive(:max_by)
        bandit.select_arm
      end
    end

    context "with arms having different success rates" do
      before do
        arms.first.trials = 100
        arms.first.successes = 80 # 80% success

        arms.last.trials = 100
        arms.last.successes = 20 # 20% success
      end

      it "tends to select arm with higher success rate" do
        # 統計的な性質をテストするため、複数回試行
        selections = 1000.times.map { bandit.select_arm }
        arm1_count = selections.count(arms.first)
        arm2_count = selections.count(arms.last)

        # 報酬の高いarm1の方が多く選ばれるはず
        expect(arm1_count).to be > arm2_count
      end
    end

    context "with extreme cases" do
      before do
        arms.first.trials = 10
        arms.last.trials = 10
      end

      it "prefers arm with all successes" do
        arms.first.successes = 10  # 全て成功
        arms.last.successes = 5    # 50% success

        selections = 1000.times.map { bandit.select_arm }
        arm1_count = selections.count(arms.first)

        # ほぼ確実にarm1が選ばれるはず
        expect(arm1_count).to be > 900
      end

      it "avoids arm with all failures" do
        arms.first.successes = 0   # 全て失敗
        arms.last.successes = 5    # 50% success

        selections = 1000.times.map { bandit.select_arm }
        arm2_count = selections.count(arms.last)

        # ほぼ確実にarm2が選ばれるはず
        expect(arm2_count).to be > 900
      end
    end
  end

  describe "sampling behavior" do
    let(:bandit) { described_class.new(arms: arms) }
    let(:samples) { 10_000.times.map { bandit.send(:ts_score, arms.first) } }

    context "Beta(1,1) fast path" do
      let(:bandit) { described_class.new(arms: arms, alpha_prior: 1.0, beta_prior: 1.0) }

      it "uses uniform distribution for untested arms" do
        # Arms with no trials should use Beta(1,1) = Uniform(0,1)
        samples = 10_000.times.map { bandit.send(:beta_sample, 1.0, 1.0) }

        expect(samples.all? { |s| s >= 0 && s <= 1 }).to be true

        # Should be approximately uniform
        mean = samples.sum / samples.size
        expect(mean).to be_within(0.05).of(0.5)
      end
    end

    context "with balanced success rate" do
      before do
        arms.first.trials = 100
        arms.first.successes = 50 # 50% success rate
      end

      it "generates samples between 0 and 1" do
        expect(samples.all? { |s| s >= 0 && s <= 1 }).to be true
      end

      it "has mean close to the true success rate" do
        mean = samples.sum / samples.size
        expect(mean).to be_within(0.05).of(0.5)
      end
    end

    context "with high success rate" do
      before do
        arms.first.trials = 1000
        arms.first.successes = 800 # 80% success rate
      end

      it "has mean close to the true success rate" do
        mean = samples.sum / samples.size
        expect(mean).to be_within(0.05).of(0.8)
      end
    end
  end
end
