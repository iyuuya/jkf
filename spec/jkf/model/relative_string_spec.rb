require 'spec_helper'

describe Jkf::Model::RelativeString do
  describe "left?" do
    it "is left" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.left).left?).to be true
    end
  end

  describe "center?" do
    it "is center" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.center).center?).to be true
    end
  end

  describe "right?" do
    it "is right" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.right).right?).to be true
    end
  end

  describe "relative_position" do
    it "is left" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.left).relative_position).to be Jkf::Model::RelativePosition.left
    end

    it "is center" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.center).relative_position).to be Jkf::Model::RelativePosition.center
    end

    it "is right" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.right).relative_position).to be Jkf::Model::RelativePosition.right
    end
  end

  describe "up?" do
    it "is up" do
      expect(described_class.new(move_direction: Jkf::Model::MoveDirection.up).up?).to be true
    end
  end

  describe "middle?" do
    it "is up" do
      expect(described_class.new(move_direction: Jkf::Model::MoveDirection.middle).middle?).to be true
    end
  end

  describe "down?" do
    it "is up" do
      expect(described_class.new(move_direction: Jkf::Model::MoveDirection.down).down?).to be true
    end
  end

  describe "move_direction" do
    it "is up" do
      expect(described_class.new(move_direction: Jkf::Model::MoveDirection.up).move_direction).to be Jkf::Model::MoveDirection.up
    end

    it "is middle" do
      expect(described_class.new(move_direction: Jkf::Model::MoveDirection.middle).move_direction).to be Jkf::Model::MoveDirection.middle
    end

    it "is down" do
      expect(described_class.new(move_direction: Jkf::Model::MoveDirection.down).move_direction).to be Jkf::Model::MoveDirection.down
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

  describe "drop?" do
    it "is drop" do
      expect(described_class.new(drop: true).drop?).to be true
    end

    it "is not drop" do
      expect(described_class.new(drop: false).drop?).to be false
    end
  end

  describe "to_jkf" do
    it "is left up hit" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.left,
                                 move_direction: Jkf::Model::MoveDirection.up, hit: true).to_jkf).to eq "LUH"
    end

    it "is left up drop" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.left,
                                 move_direction: Jkf::Model::MoveDirection.up, drop: true).to_jkf).to eq "LUH"
    end

    it "is center" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.center).to_jkf).to eq "C"
    end

    it "is right down" do
      expect(described_class.new(relative_position: Jkf::Model::RelativePosition.right,
                                 move_direction: Jkf::Model::MoveDirection.down).to_jkf).to eq "RD"
    end
  end

  describe "from_jkf" do
    it "is left up hit" do
      expect(described_class.from_jkf("LUH")).to eq described_class.new(
        relative_position: Jkf::Model::RelativePosition.left, move_direction: Jkf::Model::MoveDirection.up, hit: true
      )
    end

    it "is left up drop" do
      expect(described_class.from_jkf("LUH")).to eq described_class.new(
        relative_position: Jkf::Model::RelativePosition.left, move_direction: Jkf::Model::MoveDirection.up, drop: true
      )
    end

    it "is center" do
      expect(described_class.from_jkf("C")).to eq described_class.new(relative_position: Jkf::Model::RelativePosition.center)
    end

    it "is right down" do
      expect(described_class.from_jkf("RD")).to eq described_class.new(
        relative_position: Jkf::Model::RelativePosition.right, move_direction: Jkf::Model::MoveDirection.down
      )
    end
  end
end
