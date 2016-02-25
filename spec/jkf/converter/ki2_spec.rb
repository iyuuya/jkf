require "spec_helper"

describe Jkf::Converter::Ki2 do
  let(:ki2_converter) { Jkf::Converter::Ki2.new }
  let(:ki2_parser) { Jkf::Parser::Ki2.new }

  subject { ki2_parser.parse(ki2_converter.convert(jkf)) }

  shared_examples(:parse_file) do |filename|
    let(:str) do
      if File.extname(filename) == ".ki2"
        File.read(filename, encoding: "Shift_JIS").toutf8
      else
        File.read(filename).toutf8
      end
    end
    let(:jkf) { ki2_parser.parse(str).to_json }

    it "should be parse #{File.basename(filename)}" do
      is_expected.to eq JSON.parse(jkf)
    end
  end

  fixtures(:ki2).each do |fixture|
    it_behaves_like :parse_file, fixture
  end

  describe "#csa2relative(relative)" do
    let(:pairs) do
      {
        "L" => "左",
        "C" => "直",
        "R" => "右",
        "U" => "上",
        "M" => "寄",
        "D" => "引",
        "H" => "打"
      }
    end

    it "should convert csa to relative string" do
      pairs.each do |csa, relative_str|
        expect(ki2_converter.send(:csa2relative, csa)).to eq relative_str
      end

      expect(ki2_converter.send(:csa2relative, "UNKOWN")).to eq ""
    end
  end
end
