require 'spec_helper'

describe Jkf::Model::Color do
  describe "black" do
    it "is black" do
      expect(described_class.black.black?).to be true
    end

    it "is not white" do
      expect(described_class.black.white?).to be false
    end
  end

  describe "white" do
    it "is white" do
      expect(described_class.white.white?).to be true
    end

    it "is not black" do
      expect(described_class.white.black?).to be false
    end
  end

  describe "from_jkf" do
    it "is black" do
      expect(described_class.from_jkf(0)).to be described_class.black
    end

    it "is white" do
      expect(described_class.from_jkf(1)).to be described_class.white
    end

    it "is invalid" do
      expect { described_class.from_jkf(2) }.to raise_error(Jkf::Model::UnknownValueError, '2')
    end
  end

  describe Jkf::Model::Color::Black do
    describe "to_jkf" do
      it "is 0" do
        expect(Jkf::Model::Color.black.to_jkf).to be 0
      end
    end

    describe "from_jkf" do
      it "is black" do
        expect(described_class.from_jkf(0)).to be described_class.instance
      end

      it "is white" do
        expect { described_class.from_jkf(1) }.to raise_error(Jkf::Model::UnknownValueError, '1')
      end
    end
  end

  describe Jkf::Model::Color::White do
    describe "to_jkf" do
      it "is 1" do
        expect(Jkf::Model::Color.white.to_jkf).to be 1
      end
    end

    describe "from_jkf" do
      it "is black" do
        expect { described_class.from_jkf(0) }.to raise_error(Jkf::Model::UnknownValueError, '0')
      end

      it "is white" do
        expect(described_class.from_jkf(1)).to be described_class.instance
      end
    end
  end
end
