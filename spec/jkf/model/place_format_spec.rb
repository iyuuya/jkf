require "spec_helper"

describe Jkf::Model::PlaceFormat do
  describe "file" do
    it "responds" do
      expect(described_class.new).to respond_to(:file)
    end

    it "can be read" do
      expect(described_class.new(file: 3, rank: 4).file).to be 3
    end
  end

  describe "rank" do
    it "responds" do
      expect(described_class.new(file: 3, rank: 4).rank).to be 4
    end
  end

  describe "to_jkf" do
    it "works" do
      expect(described_class.new(file: 3, rank: 4).to_jkf).to eq({ "x" => 3, "y" => 4 })
    end
  end

  describe "from_jkf" do
    it "works" do
      expect(described_class.from_jkf({ "x" => 3, "y" => 4 })).to eq described_class.new(file: 3, rank: 4)
    end
  end
end
