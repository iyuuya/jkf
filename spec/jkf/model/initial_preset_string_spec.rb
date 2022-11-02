require 'spec_helper'

describe Jkf::Model::InitialPresetString do
  describe "even" do
    it "responds" do
      expect(described_class).to respond_to(:even)
    end
  end

  describe "lance" do
    it "responds" do
      expect(described_class).to respond_to(:lance)
    end
  end

  describe "right_lance" do
    it "responds" do
      expect(described_class).to respond_to(:right_lance)
    end
  end

  describe "bishop" do
    it "responds" do
      expect(described_class).to respond_to(:bishop)
    end
  end

  describe "rook" do
    it "responds" do
      expect(described_class).to respond_to(:rook)
    end
  end

  describe "rook_and_lance" do
    it "responds" do
      expect(described_class).to respond_to(:rook_and_lance)
    end
  end

  describe "two" do
    it "responds" do
      expect(described_class).to respond_to(:two)
    end
  end

  describe "three" do
    it "responds" do
      expect(described_class).to respond_to(:three)
    end
  end

  describe "four" do
    it "responds" do
      expect(described_class).to respond_to(:four)
    end
  end

  describe "five" do
    it "responds" do
      expect(described_class).to respond_to(:five)
    end
  end

  describe "left_five" do
    it "responds" do
      expect(described_class).to respond_to(:left_five)
    end
  end

  describe "six" do
    it "responds" do
      expect(described_class).to respond_to(:six)
    end
  end

  describe "left_seven" do
    it "responds" do
      expect(described_class).to respond_to(:left_seven)
    end
  end

  describe "right_seven" do
    it "responds" do
      expect(described_class).to respond_to(:right_seven)
    end
  end

  describe "eight" do
    it "responds" do
      expect(described_class).to respond_to(:eight)
    end
  end

  describe "ten" do
    it "responds" do
      expect(described_class).to respond_to(:ten)
    end
  end

  describe "other" do
    it "responds" do
      expect(described_class).to respond_to(:other)
    end
  end

  describe "from_jkf" do
    it "is even" do
      expect(described_class.from_jkf("HIRATE")).to be described_class.even
    end

    it "is lance" do
      expect(described_class.from_jkf("KY")).to be described_class.lance
    end

    it "is right_lance" do
      expect(described_class.from_jkf("KY_R")).to be described_class.right_lance
    end

    it "is bishop" do
      expect(described_class.from_jkf("KA")).to be described_class.bishop
    end

    it "is rook" do
      expect(described_class.from_jkf("HI")).to be described_class.rook
    end

    it "is rook and lance" do
      expect(described_class.from_jkf("HIKY")).to be described_class.rook_and_lance
    end

    it "is two" do
      expect(described_class.from_jkf("2")).to be described_class.two
    end

    it "is three" do
      expect(described_class.from_jkf("3")).to be described_class.three
    end

    it "is four" do
      expect(described_class.from_jkf("4")).to be described_class.four
    end

    it "is five" do
      expect(described_class.from_jkf("5")).to be described_class.five
    end

    it "is left five" do
      expect(described_class.from_jkf("5_L")).to be described_class.left_five
    end

    it "is six" do
      expect(described_class.from_jkf("6")).to be described_class.six
    end

    it "is left seven" do
      expect(described_class.from_jkf("7_L")).to be described_class.left_seven
    end

    it "is right seven" do
      expect(described_class.from_jkf("7_R")).to be described_class.right_seven
    end

    it "is eight" do
      expect(described_class.from_jkf("8")).to be described_class.eight
    end

    it "is ten" do
      expect(described_class.from_jkf("10")).to be described_class.ten
    end

    it "is other" do
      expect(described_class.from_jkf("OTHER")).to be described_class.other
    end
  end

  describe described_class::Even do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "HIRATE"
      end
    end
  end

  describe described_class::Lance do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "KY"
      end
    end
  end

  describe described_class::RightLance do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "KY_R"
      end
    end
  end

  describe described_class::Bishop do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "KA"
      end
    end
  end

  describe described_class::Rook do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "HI"
      end
    end
  end

  describe described_class::RookAndLance do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "HIKY"
      end
    end
  end

  describe described_class::Two do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "2"
      end
    end
  end

  describe described_class::Three do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "3"
      end
    end
  end

  describe described_class::Four do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "4"
      end
    end
  end

  describe described_class::Five do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "5"
      end
    end
  end

  describe described_class::LeftFive do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "5_L"
      end
    end
  end

  describe described_class::Six do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "6"
      end
    end
  end

  describe described_class::LeftSeven do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "7_L"
      end
    end
  end

  describe described_class::RightSeven do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "7_R"
      end
    end
  end

  describe described_class::Eight do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "8"
      end
    end
  end

  describe described_class::Ten do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "10"
      end
    end
  end

  describe described_class::Other do
    describe "to_jkf" do
      it "works" do
        expect(described_class.instance.to_jkf).to eq "OTHER"
      end
    end
  end
end
