require "spec_helper"

describe Jkf::Converter::Csa do
  subject { csa_parser.parse(csa_converter.convert(jkf)) }

  let(:csa_converter) { Jkf::Converter::Csa.new }
  let(:csa_parser) { Jkf::Parser::Csa.new }

  shared_examples('parse file') do |filename|
    let(:str) do
      if File.extname(filename) == ".csa"
        File.read(filename, encoding: "Shift_JIS").toutf8
      else
        File.read(filename).toutf8
      end
    end
    let(:jkf) { csa_parser.parse(str).to_json }

    it "is parse #{File.basename(filename)}" do
      expect(subject).to eq JSON.parse(jkf)
    end
  end

  fixtures(:csa).each do |fixture|
    it_behaves_like 'parse file', fixture
  end

  describe "#convert_preset(preset)" do
    let(:pairs) do
      {
        "HIRATE" => "",
        "KY" => "11KY",
        "KY_R" => "91KY",
        "KA" => "22KA",
        "HI" => "82HI",
        "HIKY" => "22HI11KY91KY",
        "2" => "82HI22KA",
        "3" => "82HI22KA91KY",
        "4" => "82HI22KA11KY91KY",
        "5" => "82HI22KA81KE11KY91KY",
        "5_L" => "82HI22KA21KE11KY91KY",
        "6" => "82HI22KA21KE81KE11KY91KY",
        "8" => "82HI22KA31GI71GI21KE81KE11KY91KY",
        "10" => "82HI22KA41KI61KI31GI71GI21KE81KE11KY91KY"
      }
    end

    it "converts preset to PIXXX" do
      pairs.each do |preset, pi|
        expect(csa_converter.send(:convert_preset, preset)).to eq "PI" + pi
      end
    end

    context "when 8mai" do
      let(:kif_parser) { Jkf::Parser::Kif.new }
      let(:filename) { fixtures(:kif).detect { |file| file =~ /8mai/ } }
      let(:jkf) { kif_parser.parse(File.read(filename, encoding: "Shift_JIS").toutf8) }

      it { expect(csa_converter.convert(jkf)).to be_a String }
    end
  end
end
