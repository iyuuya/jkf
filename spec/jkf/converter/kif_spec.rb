require 'spec_helper'

describe Jkf::Converter::Kif do
  let(:kif_converter) { Jkf::Converter::Kif.new }
  let(:kif_parser) { Jkf::Parser::Kif.new }

  subject { kif_parser.parse(kif_converter.convert(jkf)) }

  shared_examples(:parse_file) do |filename|
    let(:str) do
      if File.extname(filename) == '.kif'
        File.read(filename, encoding: 'Shift_JIS').toutf8
      else
        File.read(filename).toutf8
      end
    end
    let(:jkf) { kif_parser.parse(str).to_json }

    it "should be parse #{File.basename(filename)}" do
      is_expected.to eq JSON.parse(jkf)
    end
  end

  fixtures(:kif).each do |fixture|
    it_behaves_like :parse_file, fixture
  end
end
