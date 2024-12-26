# frozen_string_literal: true

RSpec.describe ClassicBandit::Arm do
  describe "#initialize" do
    context "with only id provided" do
      let(:arm) { described_class.new(id: 1) }

      it "sets id" do
        expect(arm.id).to eq(1)
      end

      it "uses id.to_s as name" do
        expect(arm.name).to eq("1")
      end

      it "initializes trials to 0" do
        expect(arm.trials).to eq(0)
      end

      it "initializes successes to 0" do
        expect(arm.successes).to eq(0)
      end
    end

    context "with all parameters provided" do
      let(:arm) do
        described_class.new(
          id: "banner_a",
          name: "Spring Campaign",
          trials: 100,
          successes: 10
        )
      end

      it "sets all attributes correctly" do
        expect(arm.id).to eq("banner_a")
        expect(arm.name).to eq("Spring Campaign")
        expect(arm.trials).to eq(100)
        expect(arm.successes).to eq(10)
      end
    end

    context "with various id types" do
      it "accepts string id" do
        arm = described_class.new(id: "banner_1")
        expect(arm.id).to eq("banner_1")
      end

      it "accepts symbol id" do
        arm = described_class.new(id: :banner1)
        expect(arm.id).to eq(:banner1)
      end

      it "accepts integer id" do
        arm = described_class.new(id: 1)
        expect(arm.id).to eq(1)
      end
    end
  end

  describe "attribute accessors" do
    let(:arm) { described_class.new(id: 1) }

    it "allows updating trials" do
      arm.trials = 5
      expect(arm.trials).to eq(5)
    end

    it "allows updating successes" do
      arm.successes = 3
      expect(arm.successes).to eq(3)
    end

    it "does not allow updating id" do
      expect { arm.id = 2 }.to raise_error(NoMethodError)
    end

    it "does not allow updating name" do
      expect { arm.name = "new_name" }.to raise_error(NoMethodError)
    end
  end
end
