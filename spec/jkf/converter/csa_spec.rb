require "spec_helper"

describe Jkf::Converter::Csa do
  let(:csa_converter) { Jkf::Converter::Csa.new }
  let(:csa_parser) { Jkf::Parser::Csa.new }

  subject { csa_parser.parse(csa_converter.convert(jkf)) }

  shared_examples(:parse_file) do |filename|
    let(:str) do
      if File.extname(filename) == ".csa"
        File.read(filename, encoding: "Shift_JIS").toutf8
      else
        File.read(filename).toutf8
      end
    end
    let(:jkf) { csa_parser.parse(str).to_json }

    it "should be parse #{File.basename(filename)}" do
      is_expected.to eq JSON.parse(jkf)
    end
  end

  fixtures(:csa).each do |fixture|
    it_behaves_like :parse_file, fixture
  end
end
