require 'spec_helper'

describe Jkf::Parser::Ki2 do
  let(:ki2_parser) { Jkf::Parser::Ki2.new }
  subject { ki2_parser.parse(str) }

  shared_examples(:parse_file) do |filename|
    let(:str) do
      if File.extname(filename) == '.ki2'
        File.read(filename, encoding: 'Shift_JIS').toutf8
      else
        File.read(filename).toutf8
      end
    end
    it "should be parse #{File.basename(filename)}" do
      is_expected.not_to be_nil
    end
  end

  fixtures(:ki2).each do |fixture|
    it_behaves_like :parse_file, fixture
  end

  context 'simple' do
    let(:str) { "▲７六歩 △３四歩 ▲２二角成 △同　銀 ▲４五角" }

    it {
      is_expected.to eq Hash[
        header:{},
        moves:[
          {},
          {move:{to:pos(7,6),piece:"FU"}},
          {move:{to:pos(3,4),piece:"FU"}},
          {move:{to:pos(2,2),piece:"KA",promote:true}},
          {move:{same:true,piece:"GI"}},
          {move:{to:pos(4,5),piece:"KA"}},
        ]
      ]
    }
  end

  context 'special' do
    let(:str) { "▲７六歩 △３四歩 ▲７八銀 △８八角成\nまで4手で後手の勝ち\n" }

    it {
      is_expected.to eq Hash[
        header:{},
        moves:[
          {},
          {move:{to:pos(7,6),piece:"FU"}},
          {move:{to:pos(3,4),piece:"FU"}},
          {move:{to:pos(7,8),piece:"GI"}},
          {move:{to:pos(8,8),piece:"KA",promote:true}},
          {special:"TORYO"},
        ]
      ]
    }
  end
end
