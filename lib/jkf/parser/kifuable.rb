module Jkf::Parser
  module Kifuable
    def parse_nonl
      match_regexp(/^[^\r\n]/)
    end

    def parse_nonls
      stack = []
      matched = parse_nonl
      while matched != :failed
        stack << matched
        matched = parse_nonl
      end
      stack
    end

    def parse_nonls!
      matched = parse_nonls
      if matched.empty?
        :failed
      else
        matched
      end
    end

    protected

    def transform_root_header_data(ret)
      if ret["header"]["手番"]
        ret["initial"]["data"]["color"] = "下先".include?(ret["header"]["手番"]) ? 0 : 1
        ret["header"].delete("手番")
      else
        ret["initial"]["data"]["color"] = 0
      end
      ret["initial"]["data"]["hands"] = [
        make_hand(ret["header"]["先手の持駒"] || ret["header"]["下手の持駒"]),
        make_hand(ret["header"]["後手の持駒"] || ret["header"]["上手の持駒"])
      ]
      %w(先手の持駒 下手の持駒 後手の持駒 上手の持駒).each do |key|
        ret["header"].delete(key)
      end
    end

    def transform_root_forks(forks, moves)
      fork_stack = [{ "te" => 0, "moves" => moves }]
      forks.each do |f|
        now_fork = f
        _fork = fork_stack.pop
        _fork = fork_stack.pop while _fork["te"] > now_fork["te"]
        move = _fork["moves"][now_fork["te"] - _fork["te"]]
        move["forks"] ||= []
        move["forks"] << now_fork["moves"]
        fork_stack << _fork
        fork_stack << now_fork
      end
    end

    def transform_initialboard(lines)
      board = []
      9.times do |i|
        line = []
        9.times do |j|
          line << lines[j][8 - i]
        end
        board << line
      end
      { "preset" => "OTHER", "data" => { "board" => board } }
    end

    def zen2n(s)
      "０１２３４５６７８９".index(s)
    end

    def kan2n(s)
      "〇一二三四五六七八九".index(s)
    end

    def kan2n2(s)
      case s.length
      when 1
        "〇一二三四五六七八九十".index(s)
      when 2
        "〇一二三四五六七八九十".index(s[1]) + 10
      else
        raise "21以上の数値に対応していません"
      end
    end

    def kind2csa(kind)
      if kind[0] == "成"
        {
          "香" => "NY",
          "桂" => "NK",
          "銀" => "NG"
        }[kind[1]]
      else
        {
          "歩" => "FU",
          "香" => "KY",
          "桂" => "KE",
          "銀" => "GI",
          "金" => "KI",
          "角" => "KA",
          "飛" => "HI",
          "玉" => "OU",
          "王" => "OU",
          "と" => "TO",
          "杏" => "NY",
          "圭" => "NK",
          "全" => "NG",
          "馬" => "UM",
          "竜" => "RY",
          "龍" => "RY"
        }[kind]
      end
    end

    def preset2str(preset)
      {
        "平手" => "HIRATE",
        "香落ち" => "KY",
        "右香落ち" => "KY_R",
        "角落ち" => "KA",
        "飛車落ち" => "HI",
        "飛香落ち" => "HIKY",
        "二枚落ち" => "2",
        "三枚落ち" => "3",
        "四枚落ち" => "4",
        "五枚落ち" => "5",
        "左五枚落ち" => "5_L",
        "六枚落ち" => "6",
        "八枚落ち" => "8",
        "十枚落ち" => "10",
        "その他" => "OTHER"
      }[preset.gsub(/\s/, "")]
    end
  end
end
