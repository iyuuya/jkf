require 'spec_helper'

describe Jkf::Model::RelativeString do
  describe "relative_position" do
    it "is left" do
      expect(described_class.new(relative_position: described_class::RelativePosition.left).relative_position).to be described_class::RelativePosition.left
    end

    it "is center" do
      expect(described_class.new(relative_position: described_class::RelativePosition.center).relative_position).to be described_class::RelativePosition.center
    end

    it "is right" do
      expect(described_class.new(relative_position: described_class::RelativePosition.right).relative_position).to be described_class::RelativePosition.right
    end
  end

  describe "move_direction" do
    it "is up" do
      expect(described_class.new(move_direction: described_class::MoveDirection.up).move_direction).to be described_class::MoveDirection.up
    end

    it "is middle" do
      expect(described_class.new(move_direction: described_class::MoveDirection.middle).move_direction).to be described_class::MoveDirection.middle
    end

    it "is down" do
      expect(described_class.new(move_direction: described_class::MoveDirection.down).move_direction).to be described_class::MoveDirection.down
    end
  end

  describe "hit?" do
    it "is hit" do
      expect(described_class.new(hit: true).hit?).to be true
    end

    it "is not hit" do
      expect(described_class.new(hit: false).hit?).to be false
    end
  end

  describe "to_jkf" do
    it "is left up hit" do
      expect(described_class.new(relative_position: described_class::RelativePosition.left, move_direction: described_class::MoveDirection.up, hit: true).to_jkf).to eq "LUH"
    end

    it "is center" do
      expect(described_class.new(relative_position: described_class::RelativePosition.center).to_jkf).to eq "C"
    end

    it "is right down" do
      expect(described_class.new(relative_position: described_class::RelativePosition.right, move_direction: described_class::MoveDirection.down).to_jkf).to eq "RD"
    end
  end

  describe "from_jkf" do
    it "is left up hit" do
      expect(described_class.from_jkf("LUH")).to be described_class.new(relative_position: described_class::RelativePosition.left, move_direction: described_class::MoveDirection.up, hit: true)
    end

    it "is center" do
      expect(described_class.from_jkf("C")).to be described_class.new(relative_position: described_class::RelativePosition.center)
    end

    it "is right down" do
      expect(described_class.from_jkf("RD")).to be described_class.new(relative_position: described_class::RelativePosition.right, move_direction: described_class::MoveDirection.right)
    end
  end
end
