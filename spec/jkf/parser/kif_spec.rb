require 'spec_helper'
require 'kconv'

describe Jkf::Parser::Kif do
  let(:kif_parser) { Jkf::Parser::Kif.new }
  subject { kif_parser.parse(str) }

  def pos(x, y)
    { x: x, y: y }
  end

  fixtures(:kif).each do |fixture|
    let(:str) { File.read(fixture).toutf8 }
    it "should be parse #{File.basename(fixture)}" do
      is_expected.not_to be_nil
    end
  end

  context 'simple' do
    let(:str) { "1 ７六歩(77)\n2 ３四歩(33)\n3 ２二角成(88)\n 4 同　銀(31)\n5 ４五角打\n" }
    it {
      is_expected.to eq Hash[{
        header: {},
        moves: [
          {},
          {move:{from:pos(7,7),to:pos(7,6),piece:"FU"}},
          {move:{from:pos(3,3),to:pos(3,4),piece:"FU"}},
          {move:{from:pos(8,8),to:pos(2,2),piece:"KA",promote:true}},
          {move:{from:pos(3,1),same:true,piece:"GI"}},
          {move:{to:pos(4,5),piece:"KA"}},
        ]
      }]
    }
  end

  context 'comment' do
    let(:str) { "*開始時コメント\n1 ７六歩(77)\n*初手コメント\n*初手コメント2\n2 ３四歩(33)\n3 ２二角成(88)\n" }
    it {
      is_expected.to eq Hash[{
        header:{},
        moves:[
          {comments:["開始時コメント"]},
          {move:{from:pos(7,7),to:pos(7,6),piece:"FU"},comments:["初手コメント", "初手コメント2"]},
          {move:{from:pos(3,3),to:pos(3,4),piece:"FU"}},
          {move:{from:pos(8,8),to:pos(2,2),piece:"KA",promote:true}},
        ]
      }]
    }
  end

  context 'time' do
    let(:str) { "1 ７六歩(77) (0:01/00:00:01)\n2 ３四歩(33) (0:02/00:00:02)\n3 ２二角成(88) (0:20/00:00:21)\n 4 同　銀(31) (0:03/00:00:05)\n5 ４五角打 (0:39/00:01:00)\n" }
    it {
      is_expected.to eq Hash[{
        header:{},
        moves:[
          {},
          {move:{from:pos(7,7),to:pos(7,6),piece:"FU"},time:{now:{m:0,s:1},total:{h:0,m:0,s:1}}},
          {move:{from:pos(3,3),to:pos(3,4),piece:"FU"},time:{now:{m:0,s:2},total:{h:0,m:0,s:2}}},
          {move:{from:pos(8,8),to:pos(2,2),piece:"KA",promote:true},time:{now:{m:0,s:20},total:{h:0,m:0,s:21}}},
          {move:{from:pos(3,1),same:true,piece:"GI"},time:{now:{m:0,s:3},total:{h:0,m:0,s:5}}},
          {move:{to:pos(4,5),piece:"KA"},time:{now:{m:0,s:39},total:{h:0,m:1,s:0}}},
        ]
      }]
    }
  end

  context 'special' do
    let(:str) { "1 ７六歩(77)\n2 ３四歩(33)\n3 ７八銀(79)\n 4 ８八角成(22)\n5 投了\nまで4手で後手の勝ち\n" }
    it {
      is_expected.to eq Hash[{
        header:{},
        moves:[
          {},
          {move:{from:pos(7,7),to:pos(7,6),piece:"FU"}},
          {move:{from:pos(3,3),to:pos(3,4),piece:"FU"}},
          {move:{from:pos(7,9),to:pos(7,8),piece:"GI"}},
          {move:{from:pos(2,2),to:pos(8,8),piece:"KA",promote:true}},
          {special:"TORYO"},
        ]
      }]
    }
  end
end
