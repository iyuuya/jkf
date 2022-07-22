require "spec_helper"

describe Jkf do
  it "has a version number" do
    expect(Jkf::VERSION).not_to be_nil
  end

  describe ".parse_file(filename, encoding)" do
    subject { Jkf.parse_file(filename) }

    context "when .kif" do
      let(:filename) { fixtures(:kif).first }

      it { is_expected.to be_a Hash }
    end

    context "when .ki2" do
      let(:filename) { fixtures(:ki2).first }

      it { is_expected.to be_a Hash }
    end

    context "when .csa" do
      let(:filename) { fixtures(:csa).first }

      it { is_expected.to be_a Hash }
    end

    context "when .jkf" do
      let(:filename) { fixtures(:jkf).first }

      it { is_expected.to be_a Hash }
    end

    context "when .csv" do
      let(:filename) { fixtures(:csv).first }

      it { expect { subject }.to raise_error(Jkf::FileTypeError) }
    end
  end

  describe ".parse(str)" do
    subject { Jkf.parse(str) }

    context "with kif str" do
      let(:str) { File.read(fixtures(:kif).first, encoding: "Shift_JIS").toutf8 }

      it { is_expected.to be_a Hash }
    end

    context "with ki2 str" do
      let(:str) { File.read(fixtures(:ki2).first, encoding: "Shift_JIS").toutf8 }

      it { is_expected.to be_a Hash }
    end

    context "with csa str" do
      let(:str) { File.read(fixtures(:csa).first, encoding: "Shift_JIS").toutf8 }

      it { is_expected.to be_a Hash }
    end

    context "with jkf str" do
      let(:str) { File.read(fixtures(:jkf).first, encoding: "Shift_JIS").toutf8 }

      it { is_expected.to be_a Hash }
    end

    context "with csv str" do
      let(:str) { File.read(fixtures(:csv).first, encoding: "Shift_JIS").toutf8 }

      it { expect { subject }.to raise_error(Jkf::FileTypeError) }
    end
  end
end
