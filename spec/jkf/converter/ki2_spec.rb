require 'spec_helper'

describe Jkf::Converter::Ki2 do
  let(:ki2_converter) { Jkf::Converter::Ki2.new }
  let(:ki2_parser) { Jkf::Parser::Ki2.new }

  subject { ki2_parser.parse(ki2_converter.convert(jkf)) }

  describe '9fu.ki2' do
    let(:jkf) { ki2_parser.parse(File.read(fixtures(:ki2).find { |file| file =~ /9fu/ } , encoding: 'Shift_JIS').toutf8).to_json }

    it { is_expected.to eq JSON.parse(jkf) }
  end

  describe 'fork.ki2' do
    let(:jkf) { ki2_parser.parse(File.read(fixtures(:ki2).find { |file| file =~ /fork/ } , encoding: 'Shift_JIS').toutf8).to_json }

    it { is_expected.to eq JSON.parse(jkf) }
  end
end
