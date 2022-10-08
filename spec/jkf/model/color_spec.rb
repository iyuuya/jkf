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
end
