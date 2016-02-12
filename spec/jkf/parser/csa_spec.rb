require 'spec_helper'
require 'pry'

describe Jkf::Parser::Csa do
  let(:csa_parser) { Jkf::Parser::Csa.new }
  subject { csa_parser.parse(str) }

  describe 'csa-parser V2' do
    let(:initial) {
      Hash[
        preset: "OTHER",
        data: {
          board: [
            [{ color: 1, kind: "KY" }, {}, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, {}, { color: 0, kind: "KY" },],
            [{ color: 1, kind: "KE" }, { color: 1, kind: "KA" }, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, { color: 0, kind: "HI" }, { color: 0, kind: "KE" },],
            [{ color: 1, kind: "GI" }, {}, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, {}, { color: 0, kind: "GI" },],
            [{ color: 1, kind: "KI" }, {}, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, {}, { color: 0, kind: "KI" },],
            [{ color: 1, kind: "OU" }, {}, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, {}, { color: 0, kind: "OU" },],
            [{ color: 1, kind: "KI" }, {}, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, {}, { color: 0, kind: "KI" },],
            [{ color: 1, kind: "GI" }, {}, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, {}, { color: 0, kind: "GI" },],
            [{ color: 1, kind: "KE" }, { color: 1, kind: "HI" }, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, { color: 0, kind: "KA" }, { color: 0, kind: "KE" },],
            [{ color: 1, kind: "KY" }, {}, { color: 1, kind: "FU" }, {}, {}, {}, { color: 0, kind: "FU" }, {}, { color: 0, kind: "KY" },],
          ],
          color: 0,
          hands:[
            {"FU"=>0,"KY"=>0,"KE"=>0,"GI"=>0,"KI"=>0,"KA"=>0,"HI"=>0},
            {"FU"=>0,"KY"=>0,"KE"=>0,"GI"=>0,"KI"=>0,"KA"=>0,"HI"=>0},
          ]
        }
      ]
    }

    context 'simple' do
      let(:str) { "\
V2.2\n\
PI\n\
+\n\
+7776FU\n\
-3334FU\n\
+8822UM\n\
-3122GI\n\
+0045KA\n"
      }

      it {
        is_expected.to eq Hash[
          header:{},
          initial: initial,
          moves:[
            {},
            {move:{from:pos(7,7),to:pos(7,6),piece:"FU"}},
            {move:{from:pos(3,3),to:pos(3,4),piece:"FU"}},
            {move:{from:pos(8,8),to:pos(2,2),piece:"UM"}},
            {move:{from:pos(3,1),to:pos(2,2),piece:"GI"}},
            {move:{to:pos(4,5),piece:"KA"}},
          ]
        ]
      }
    end

    context 'comment' do
      let(:str) { "\
V2.2\n\
PI\n\
+\n\
'開始時コメント\n\
+7776FU\n\
'初手コメント\n\
'初手コメント2\n\
-3334FU\n\
+8822UM\n"
      }
      it {
        is_expected.to eq Hash[
          header:{},
          initial: initial,
          moves:[
            {comments:["開始時コメント"]},
            {move:{from:pos(7,7),to:pos(7,6),piece:"FU"},comments:["初手コメント", "初手コメント2"]},
            {move:{from:pos(3,3),to:pos(3,4),piece:"FU"}},
            {move:{from:pos(8,8),to:pos(2,2),piece:"UM"}},
          ]
        ]
      }
    end

    context 'special' do
      let(:str) { "\
V2.2\n\
PI\n\
+\n\
+7776FU\n\
-3334FU\n\
+7978GI\n\
-2288UM\n\
%TORYO\n"
      }

      it {
        is_expected.to eq Hash[
          header:{},
          initial: initial,
          moves:[
            {},
            {move:{from:pos(7,7),to:pos(7,6),piece:"FU"}},
            {move:{from:pos(3,3),to:pos(3,4),piece:"FU"}},
            {move:{from:pos(7,9),to:pos(7,8),piece:"GI"}},
            {move:{from:pos(2,2),to:pos(8,8),piece:"UM"}},
            {special:"TORYO"},
          ]
        ]
      }
    end

    context 'comma' do
      let(:str) { "\
V2.2\n\
PI\n\
+\n\
+7776FU,T12,-3334FU,T2\n\
+8822UM,T100\n\
-3122GI,T1\n\
+0045KA,T0\n"
      }

      it {
        is_expected.to eq Hash[
          header:{},
          initial: initial,
          moves:[
            {},
            {move:{from:pos(7,7),to:pos(7,6),piece:"FU"},time:{now:{m:0,s:12}}},
            {move:{from:pos(3,3),to:pos(3,4),piece:"FU"},time:{now:{m:0,s:2}}},
            {move:{from:pos(8,8),to:pos(2,2),piece:"UM"},time:{now:{m:1,s:40}}},
            {move:{from:pos(3,1),to:pos(2,2),piece:"GI"},time:{now:{m:0,s:1}}},
            {move:{to:pos(4,5),piece:"KA"},time:{now:{m:0,s:0}}},
          ]
        ]
      }
    end

    context 'time' do
      let(:str) { "\
V2.2\n\
PI\n\
+\n\
+7776FU\n\
T12\n\
-3334FU\n\
T2\n\
+8822UM\n\
T100\n\
-3122GI\n\
T1\n\
+0045KA\n\
T0\n"
      }

      it {
        is_expected.to eq Hash[
          header:{},
          initial: initial,
          moves:[
            {},
            {move:{from:pos(7,7),to:pos(7,6),piece:"FU"},time:{now:{m:0,s:12}}},
            {move:{from:pos(3,3),to:pos(3,4),piece:"FU"},time:{now:{m:0,s:2}}},
            {move:{from:pos(8,8),to:pos(2,2),piece:"UM"},time:{now:{m:1,s:40}}},
            {move:{from:pos(3,1),to:pos(2,2),piece:"GI"},time:{now:{m:0,s:1}}},
            {move:{to:pos(4,5),piece:"KA"},time:{now:{m:0,s:0}}},
          ]
        ]
      }
    end
  end
end
