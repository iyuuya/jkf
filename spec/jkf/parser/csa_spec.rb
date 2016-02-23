require "spec_helper"

describe Jkf::Parser::Csa do
  let(:csa_parser) { Jkf::Parser::Csa.new }
  subject { csa_parser.parse(str) }

  shared_examples(:parse_file) do |filename|
    let(:str) do
      File.read(filename).toutf8
    end
    it "should be parse #{File.basename(filename)}" do
      is_expected.not_to be_nil
    end
  end

  fixtures(:csa).each do |fixture|
    it_behaves_like :parse_file, fixture
  end

  describe "csa-parser V2" do
    let(:initial) do
      Hash[
        "preset" => "OTHER",
        "data" => {
          "board" => [
            [{ "color" => 1, "kind" => "KY" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
            [{ "color" => 1, "kind" => "KE" }, { "color" => 1, "kind" => "KA" },
             { "color" => 1, "kind" => "FU" }, {}, {}, {}, { "color" => 0, "kind" => "FU" },
             { "color" => 0, "kind" => "HI" }, { "color" => 0, "kind" => "KE" }],
            [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
            [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
            [{ "color" => 1, "kind" => "OU" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "OU" }],
            [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
            [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
            [{ "color" => 1, "kind" => "KE" }, { "color" => 1, "kind" => "HI" },
             { "color" => 1, "kind" => "FU" }, {}, {}, {}, { "color" => 0, "kind" => "FU" },
             { "color" => 0, "kind" => "KA" }, { "color" => 0, "kind" => "KE" }],
            [{ "color" => 1, "kind" => "KY" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
          ],
          "color" => 0,
          "hands" => [
            { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
            { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
          ]
        }
      ]
    end

    context "simple" do
      let(:str) do
        <<EOS
V2.2
PI
+
+7776FU
-3334FU
+8822UM
-3122GI
+0045KA
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 } },
            { "move" => { "from" => pos(8, 8), "to" => pos(2, 2), "piece" => "UM", "color" => 0 } },
            { "move" => { "from" => pos(3, 1), "to" => pos(2, 2), "piece" => "GI", "color" => 1 } },
            { "move" => { "to" => pos(4, 5), "piece" => "KA", "color" => 0 } },
          ]
        ]
      end
    end

    context "comment" do
      let(:str) do
        <<EOS
V2.2
PI
+
'開始時コメント
+7776FU
'初手コメント
'初手コメント2
-3334FU
+8822UM
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            { "comments" => ["開始時コメント"] },
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 },
              "comments" => ["初手コメント", "初手コメント2"] },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 } },
            { "move" => { "from" => pos(8, 8), "to" => pos(2, 2), "piece" => "UM", "color" => 0 } },
          ]
        ]
      end
    end

    context "special" do
      let(:str) do
        <<EOS
V2.2
PI
+
+7776FU
-3334FU
+7978GI
-2288UM
%TORYO
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 } },
            { "move" => { "from" => pos(7, 9), "to" => pos(7, 8), "piece" => "GI", "color" => 0 } },
            { "move" => { "from" => pos(2, 2), "to" => pos(8, 8), "piece" => "UM", "color" => 1 } },
            { "special" => "TORYO" },
          ]
        ]
      end
    end

    context "comma" do
      let(:str) do
        <<EOS
V2.2
PI
+
+7776FU,T12,-3334FU,T2
+8822UM,T100
-3122GI,T1
+0045KA,T0
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 },
              "time" => { "now" => { "m" => 0, "s" => 12 } } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 },
              "time" => { "now" => { "m" => 0, "s" => 2 } } },
            { "move" => { "from" => pos(8, 8), "to" => pos(2, 2), "piece" => "UM", "color" => 0 },
              "time" => { "now" => { "m" => 1, "s" => 40 } } },
            { "move" => { "from" => pos(3, 1), "to" => pos(2, 2), "piece" => "GI", "color" => 1 },
              "time" => { "now" => { "m" => 0, "s" => 1 } } },
            { "move" => { "to" => pos(4, 5), "piece" => "KA", "color" => 0 },
              "time" => { "now" => { "m" => 0, "s" => 0 } } },
          ]
        ]
      end
    end

    context "time" do
      let(:str) do
        <<EOS
V2.2
PI
+
+7776FU
T12
-3334FU
T2
+8822UM
T100
-3122GI
T1
+0045KA
T0
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 },
              "time" => { "now" => { "m" => 0, "s" => 12 } } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 },
              "time" => { "now" => { "m" => 0, "s" => 2 } } },
            { "move" => { "from" => pos(8, 8), "to" => pos(2, 2), "piece" => "UM", "color" => 0 },
              "time" => { "now" => { "m" => 1, "s" => 40 } } },
            { "move" => { "from" => pos(3, 1), "to" => pos(2, 2), "piece" => "GI", "color" => 1 },
              "time" => { "now" => { "m" => 0, "s" => 1 } } },
            { "move" => { "to" => pos(4, 5), "piece" => "KA", "color" => 0 },
              "time" => { "now" => { "m" => 0, "s" => 0 } } },
          ]
        ]
      end
    end

    describe "開始局面" do
      context "平手初期局面" do
        let(:str) do
          <<EOS
V2.2
PI82HI22KA91KY81KE21KE11KY
-
-5142OU
+7776FU
-3122GI
+8866KA
-7182GI
EOS
        end

        it do
          is_expected.to eq Hash[
            "header" => {},
            "initial" => {
              "preset" => "OTHER",
              "data" => {
                "board" => [
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, { "color" => 0, "kind" => "HI" },
                   { "color" => 0, "kind" => "KE" }],
                  [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
                  [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
                  [{ "color" => 1, "kind" => "OU" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "OU" }],
                  [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
                  [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, { "color" => 0, "kind" => "KA" },
                   { "color" => 0, "kind" => "KE" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
                ],
                "color" => 1,
                "hands" => [
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
                ]
              }
            },
            "moves" => [
              {},
              { "move" => { "from" => pos(5, 1), "to" => pos(4, 2),
                            "piece" => "OU", "color" => 1 } },
              { "move" => { "from" => pos(7, 7), "to" => pos(7, 6),
                            "piece" => "FU", "color" => 0 } },
              { "move" => { "from" => pos(3, 1), "to" => pos(2, 2),
                            "piece" => "GI", "color" => 1 } },
              { "move" => { "from" => pos(8, 8), "to" => pos(6, 6),
                            "piece" => "KA", "color" => 0 } },
              { "move" => { "from" => pos(7, 1), "to" => pos(8, 2),
                            "piece" => "GI", "color" => 1 } },
            ]
          ]
        end
      end

      context "一括表現" do
        let(:str) do
          <<EOS
V2.2
P1 *  * -GI-KI-OU-KI-GI *  * 
P1 *  *  *  *  *  *  *  *  * 
P3-FU-FU-FU-FU-FU-FU-FU-FU-FU
P1 *  *  *  *  *  *  *  *  * 
P1 *  *  *  *  *  *  *  *  * 
P1 *  *  *  *  *  *  *  *  * 
P3+FU+FU+FU+FU+FU+FU+FU+FU+FU
P1 * +KA *  *  *  *  * +HI * 
P9+KY+KE+GI+KI+OU+KI+GI+KE+KY
-
-5142OU
+7776FU
-3122GI
+8866KA
-7182GI
EOS
        end

        it do
          is_expected.to eq Hash[
            "header" => {},
            "initial" => {
              "preset" => "OTHER",
              "data" => {
                "board" => [
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, { "color" => 0, "kind" => "HI" },
                   { "color" => 0, "kind" => "KE" }],
                  [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
                  [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
                  [{ "color" => 1, "kind" => "OU" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "OU" }],
                  [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
                  [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {},
                   {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, { "color" => 0, "kind" => "KA" },
                   { "color" => 0, "kind" => "KE" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
                ],
                "color" => 1,
                "hands" => [
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
                ]
              }
            },
            "moves" => [
              {},
              { "move" => { "from" => pos(5, 1), "to" => pos(4, 2),
                            "piece" => "OU", "color" => 1 } },
              { "move" => { "from" => pos(7, 7), "to" => pos(7, 6),
                            "piece" => "FU", "color" => 0 } },
              { "move" => { "from" => pos(3, 1), "to" => pos(2, 2),
                            "piece" => "GI", "color" => 1 } },
              { "move" => { "from" => pos(8, 8), "to" => pos(6, 6),
                            "piece" => "KA", "color" => 0 } },
              { "move" => { "from" => pos(7, 1), "to" => pos(8, 2),
                            "piece" => "GI", "color" => 1 } },
            ]
          ]
        end
      end

      context "駒別単独表現" do
        let(:str) do
          <<EOS
V2.2
P-11OU21FU22FU23FU24FU25FU26FU27FU28FU29FU
P+00HI00HI00KY00KY00KY00KY
P-00GI00GI00GI00GI00KE00KE00KE00KE
+
+0013KY
-0012KE
+1312NY
EOS
        end

        it do
          is_expected.to eq Hash[
            "header" => {},
            "initial" => {
              "preset" => "OTHER",
              "data" => {
                "board" => [
                  [{ "color" => 1, "kind" => "OU" }, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{ "color" => 1, "kind" => "FU" }, { "color" => 1, "kind" => "FU" },
                   { "color" => 1, "kind" => "FU" }, { "color" => 1, "kind" => "FU" },
                   { "color" => 1, "kind" => "FU" }, { "color" => 1, "kind" => "FU" },
                   { "color" => 1, "kind" => "FU" }, { "color" => 1, "kind" => "FU" },
                   { "color" => 1, "kind" => "FU" }],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                ],
                "color" => 0,
                "hands" => [
                  { "FU" => 0, "KY" => 4, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 2 },
                  { "FU" => 0, "KY" => 0, "KE" => 4, "GI" => 4, "KI" => 0, "KA" => 0, "HI" => 0 },
                ]
              }
            },
            "moves" => [
              {},
              { "move" => { "to" => pos(1, 3), "piece" => "KY", "color" => 0 } },
              { "move" => { "to" => pos(1, 2), "piece" => "KE", "color" => 1 } },
              { "move" => { "from" => pos(1, 3), "to" => pos(1, 2),
                            "piece" => "NY", "color" => 0 } },
            ]
          ]
        end
      end

      context "AL" do
        let(:str) do
          <<EOS
V2.2
P+23FU
P-11OU21KE
P+00KI
P-00AL
+
+0022KI
%TSUMI
EOS
        end

        it do
          is_expected.to eq Hash[
            "header" => {},
            "initial" => {
              "preset" => "OTHER",
              "data" => {
                "board" => [
                  [{ "color" => 1, "kind" => "OU" }, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{ "color" => 1, "kind" => "KE" }, {}, { "color" => 0, "kind" => "FU" },
                   {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                ],
                "color" => 0,
                "hands" => [
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 1, "KA" => 0, "HI" => 0 },
                  { "FU" => 17, "KY" => 4, "KE" => 3, "GI" => 4, "KI" => 3, "KA" => 2, "HI" => 2 },
                ]
              }
            },
            "moves" => [
              {},
              { "move" => { "to" => pos(2, 2), "piece" => "KI", "color" => 0 } },
              { "special" => "TSUMI" },
            ]
          ]
        end
      end
    end

    context "header" do
      let(:str) do
        <<EOS
V2.2
N+sente
N-gote
$SITE:将棋会館
$START_TIME:2015/08/04 13:00:00
PI
+
+7776FU
-3334FU
+7978GI
-2288UM
%TORYO
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {
            "先手" => "sente",
            "後手" => "gote",
            "場所" => "将棋会館",
            "開始日時" => "2015/08/04 13:00:00",
          },
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 } },
            { "move" => { "from" => pos(7, 9), "to" => pos(7, 8), "piece" => "GI", "color" => 0 } },
            { "move" => { "from" => pos(2, 2), "to" => pos(8, 8), "piece" => "UM", "color" => 1 } },
            { "special" => "TORYO" },
          ]
        ]
      end
    end
  end

  describe "csa-parser V1" do
    let(:initial) do
      Hash[
        "preset" => "OTHER",
        "data" => {
          "board" => [
            [{ "color" => 1, "kind" => "KY" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
            [{ "color" => 1, "kind" => "KE" }, { "color" => 1, "kind" => "KA" },
             { "color" => 1, "kind" => "FU" }, {}, {}, {}, { "color" => 0, "kind" => "FU" },
             { "color" => 0, "kind" => "HI" }, { "color" => 0, "kind" => "KE" }],
            [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
            [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
            [{ "color" => 1, "kind" => "OU" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "OU" }],
            [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
            [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
            [{ "color" => 1, "kind" => "KE" }, { "color" => 1, "kind" => "HI" },
             { "color" => 1, "kind" => "FU" }, {}, {}, {}, { "color" => 0, "kind" => "FU" },
             { "color" => 0, "kind" => "KA" }, { "color" => 0, "kind" => "KE" }],
            [{ "color" => 1, "kind" => "KY" }, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
             { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
          ],
          "color" => 0,
          "hands" => [
            { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
            { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
          ]
        }
      ]
    end

    context "simple" do
      let(:str) do
        <<EOS
PI
+
+7776FU
-3334FU
+8822UM
-3122GI
+0045KA
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 } },
            { "move" => { "from" => pos(8, 8), "to" => pos(2, 2), "piece" => "UM", "color" => 0 } },
            { "move" => { "from" => pos(3, 1), "to" => pos(2, 2), "piece" => "GI", "color" => 1 } },
            { "move" => { "to" => pos(4, 5), "piece" => "KA", "color" => 0 } },
          ]
        ]
      end
    end

    context "comment" do
      let(:str) do
        <<EOS
PI
+
'開始時コメント
+7776FU
'初手コメント
'初手コメント2
-3334FU
+8822UM
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            { "comments" => ["開始時コメント"] },
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 },
              "comments" => ["初手コメント", "初手コメント2"] },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 } },
            { "move" => { "from" => pos(8, 8), "to" => pos(2, 2), "piece" => "UM", "color" => 0 } },
          ]
        ]
      end
    end

    context "special" do
      let(:str) do
        <<EOS
PI
+
+7776FU
-3334FU
+7978GI
-2288UM
%TORYO
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 } },
            { "move" => { "from" => pos(7, 9), "to" => pos(7, 8), "piece" => "GI", "color" => 0 } },
            { "move" => { "from" => pos(2, 2), "to" => pos(8, 8), "piece" => "UM", "color" => 1 } },
            { "special" => "TORYO" },
          ]
        ]
      end
    end

    context "comma" do
      let(:str) do
        <<EOS
PI
+
+7776FU,T12,-3334FU,T2
+8822UM,T100
-3122GI,T1
+0045KA,T0
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 },
              "time" => { "now" => { "m" => 0, "s" => 12 } } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 },
              "time" => { "now" => { "m" => 0, "s" => 2 } } },
            { "move" => { "from" => pos(8, 8), "to" => pos(2, 2), "piece" => "UM", "color" => 0 },
              "time" => { "now" => { "m" => 1, "s" => 40 } } },
            { "move" => { "from" => pos(3, 1), "to" => pos(2, 2), "piece" => "GI", "color" => 1 },
              "time" => { "now" => { "m" => 0, "s" => 1 } } },
            { "move" => { "to" => pos(4, 5), "piece" => "KA", "color" => 0 },
              "time" => { "now" => { "m" => 0, "s" => 0 } } },
          ]
        ]
      end
    end

    context "time" do
      let(:str) do
        <<EOS
PI
+
+7776FU
T12
-3334FU
T2
+8822UM
T100
-3122GI
T1
+0045KA
T0
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {},
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 },
              "time" => { "now" => { "m" => 0, "s" => 12 } } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 },
              "time" => { "now" => { "m" => 0, "s" => 2 } } },
            { "move" => { "from" => pos(8, 8), "to" => pos(2, 2), "piece" => "UM", "color" => 0 },
              "time" => { "now" => { "m" => 1, "s" => 40 } } },
            { "move" => { "from" => pos(3, 1), "to" => pos(2, 2), "piece" => "GI", "color" => 1 },
              "time" => { "now" => { "m" => 0, "s" => 1 } } },
            { "move" => { "to" => pos(4, 5), "piece" => "KA", "color" => 0 },
              "time" => { "now" => { "m" => 0, "s" => 0 } } },
          ]
        ]
      end
    end

    describe "開始局面" do
      context "平手初期局面" do
        let(:str) do
          <<EOS
PI82HI22KA91KY81KE21KE11KY
-
-5142OU
+7776FU
-3122GI
+8866KA
-7182GI
EOS
        end

        it do
          is_expected.to eq Hash[
            "header" => {},
            "initial" => {
              "preset" => "OTHER",
              "data" => {
                "board" => [
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, { "color" => 0, "kind" => "HI" },
                   { "color" => 0, "kind" => "KE" }],
                  [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {},
                   {}, {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
                  [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {},
                   {}, {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
                  [{ "color" => 1, "kind" => "OU" }, {}, { "color" => 1, "kind" => "FU" }, {},
                   {}, {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "OU" }],
                  [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" }, {},
                   {}, {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KI" }],
                  [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" }, {},
                   {}, {}, { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "GI" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" },
                   {}, {}, {}, { "color" => 0, "kind" => "FU" },
                   { "color" => 0, "kind" => "KA" }, { "color" => 0, "kind" => "KE" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
                ],
                "color" => 1,
                "hands" => [
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
                ]
              }
            },
            "moves" => [
              {},
              { "move" => { "from" => pos(5, 1), "to" => pos(4, 2),
                            "piece" => "OU", "color" => 1 } },
              { "move" => { "from" => pos(7, 7), "to" => pos(7, 6),
                            "piece" => "FU", "color" => 0 } },
              { "move" => { "from" => pos(3, 1), "to" => pos(2, 2),
                            "piece" => "GI", "color" => 1 } },
              { "move" => { "from" => pos(8, 8), "to" => pos(6, 6),
                            "piece" => "KA", "color" => 0 } },
              { "move" => { "from" => pos(7, 1), "to" => pos(8, 2),
                            "piece" => "GI", "color" => 1 } },
            ]
          ]
        end
      end

      context "一括表現" do
        let(:str) do
          <<EOS
P1 *  * -GI-KI-OU-KI-GI *  * 
P1 *  *  *  *  *  *  *  *  * 
P3-FU-FU-FU-FU-FU-FU-FU-FU-FU
P1 *  *  *  *  *  *  *  *  * 
P1 *  *  *  *  *  *  *  *  * 
P1 *  *  *  *  *  *  *  *  * 
P3+FU+FU+FU+FU+FU+FU+FU+FU+FU
P1 * +KA *  *  *  *  * +HI * 
P9+KY+KE+GI+KI+OU+KI+GI+KE+KY
-
-5142OU
+7776FU
-3122GI
+8866KA
-7182GI
EOS
        end

        it do
          is_expected.to eq Hash[
            "header" => {},
            "initial" => {
              "preset" => "OTHER",
              "data" => {
                "board" => [
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, { "color" => 0, "kind" => "HI" },
                   { "color" => 0, "kind" => "KE" }],
                  [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" },
                   {}, {}, {}, { "color" => 0, "kind" => "FU" },
                   {}, { "color" => 0, "kind" => "GI" }],
                  [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" },
                   {}, {}, {}, { "color" => 0, "kind" => "FU" },
                   {}, { "color" => 0, "kind" => "KI" }],
                  [{ "color" => 1, "kind" => "OU" }, {}, { "color" => 1, "kind" => "FU" },
                   {}, {}, {}, { "color" => 0, "kind" => "FU" },
                   {}, { "color" => 0, "kind" => "OU" }],
                  [{ "color" => 1, "kind" => "KI" }, {}, { "color" => 1, "kind" => "FU" },
                   {}, {}, {}, { "color" => 0, "kind" => "FU" },
                   {}, { "color" => 0, "kind" => "KI" }],
                  [{ "color" => 1, "kind" => "GI" }, {}, { "color" => 1, "kind" => "FU" },
                   {}, {}, {}, { "color" => 0, "kind" => "FU" },
                   {}, { "color" => 0, "kind" => "GI" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, { "color" => 0, "kind" => "KA" },
                   { "color" => 0, "kind" => "KE" }],
                  [{}, {}, { "color" => 1, "kind" => "FU" }, {}, {}, {},
                   { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }],
                ],
                "color" => 1,
                "hands" => [
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
                ]
              }
            },
            "moves" => [
              {},
              { "move" => { "from" => pos(5, 1), "to" => pos(4, 2),
                            "piece" => "OU", "color" => 1 } },
              { "move" => { "from" => pos(7, 7), "to" => pos(7, 6),
                            "piece" => "FU", "color" => 0 } },
              { "move" => { "from" => pos(3, 1), "to" => pos(2, 2),
                            "piece" => "GI", "color" => 1 } },
              { "move" => { "from" => pos(8, 8), "to" => pos(6, 6),
                            "piece" => "KA", "color" => 0 } },
              { "move" => { "from" => pos(7, 1), "to" => pos(8, 2),
                            "piece" => "GI", "color" => 1 } },
            ]
          ]
        end
      end

      context "駒別単独表現" do
        let(:str) do
          <<EOS
P-11OU21FU22FU23FU24FU25FU26FU27FU28FU29FU
P+00HI00HI00KY00KY00KY00KY
P-00GI00GI00GI00GI00KE00KE00KE00KE
+
+0013KY
-0012KE
+1312NY
EOS
        end

        it do
          is_expected.to eq Hash[
            "header" => {},
            "initial" => {
              "preset" => "OTHER",
              "data" => {
                "board" => [
                  [{ "color" => 1, "kind" => "OU" }, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{ "color" => 1, "kind" => "FU" }, { "color" => 1, "kind" => "FU" },
                   { "color" => 1, "kind" => "FU" }, { "color" => 1, "kind" => "FU" },
                   { "color" => 1, "kind" => "FU" }, { "color" => 1, "kind" => "FU" },
                   { "color" => 1, "kind" => "FU" }, { "color" => 1, "kind" => "FU" },
                   { "color" => 1, "kind" => "FU" }],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                ],
                "color" => 0,
                "hands" => [
                  { "FU" => 0, "KY" => 4, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 2 },
                  { "FU" => 0, "KY" => 0, "KE" => 4, "GI" => 4, "KI" => 0, "KA" => 0, "HI" => 0 },
                ]
              }
            },
            "moves" => [
              {},
              { "move" => { "to" => pos(1, 3), "piece" => "KY", "color" => 0 } },
              { "move" => { "to" => pos(1, 2), "piece" => "KE", "color" => 1 } },
              { "move" => { "from" => pos(1, 3), "to" => pos(1, 2),
                            "piece" => "NY", "color" => 0 } },
            ]
          ]
        end
      end

      context "AL" do
        let(:str) do
          <<EOS
V2.2
P+23FU
P-11OU21KE
P+00KI
P-00AL
+
+0022KI
%TSUMI
EOS
        end

        it do
          is_expected.to eq Hash[
            "header" => {},
            "initial" => {
              "preset" => "OTHER",
              "data" => {
                "board" => [
                  [{ "color" => 1, "kind" => "OU" }, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{ "color" => 1, "kind" => "KE" }, {}, { "color" => 0, "kind" => "FU" },
                   {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                  [{}, {}, {}, {}, {}, {}, {}, {}, {}],
                ],
                "color" => 0,
                "hands" => [
                  { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 1, "KA" => 0, "HI" => 0 },
                  { "FU" => 17, "KY" => 4, "KE" => 3, "GI" => 4, "KI" => 3, "KA" => 2, "HI" => 2 },
                ]
              }
            },
            "moves" => [
              {},
              { "move" => { "to" => pos(2, 2), "piece" => "KI", "color" => 0 } },
              { "special" => "TSUMI" },
            ]
          ]
        end
      end
    end

    context "header" do
      let(:str) do
        <<EOS
N+sente
N-gote
PI
+
+7776FU
-3334FU
+7978GI
-2288UM
%TORYO
EOS
      end

      it do
        is_expected.to eq Hash[
          "header" => {
            "先手" => "sente",
            "後手" => "gote",
          },
          "initial" => initial,
          "moves" => [
            {},
            { "move" => { "from" => pos(7, 7), "to" => pos(7, 6), "piece" => "FU", "color" => 0 } },
            { "move" => { "from" => pos(3, 3), "to" => pos(3, 4), "piece" => "FU", "color" => 1 } },
            { "move" => { "from" => pos(7, 9), "to" => pos(7, 8), "piece" => "GI", "color" => 0 } },
            { "move" => { "from" => pos(2, 2), "to" => pos(8, 8), "piece" => "UM", "color" => 1 } },
            { "special" => "TORYO" },
          ]
        ]
      end
    end
  end
end
