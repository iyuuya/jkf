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

  describe Jkf::Model::Color::Black do
    describe "to_jkf" do
      it "is 0" do
        expect(Jkf::Model::Color.black.to_jkf).to be 0
      end
    end
  end

  describe Jkf::Model::Color::White do
    describe "to_jkf" do
      it "is 1" do
        expect(Jkf::Model::Color.white.to_jkf).to be 1
      end
    end
  end
end
