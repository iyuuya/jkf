module Jkf::Converter
  # CSA v2.2 Converter
  class Csa < Base
    VERSION = "2.2".freeze

    protected

    def convert_root(jkf)
      result = version
      result += convert_information(jkf["header"]) if jkf["header"]
      result += convert_initial(jkf["initial"]) if jkf["initial"]
      result += convert_moves(jkf["moves"]) if jkf["moves"]
      result
    end

    def convert_information(header)
      result = ""
      if header["先手"] || header["下手"]
        result += "N+" + (header.delete("先手") || header.delete("下手") || "") + "\n"
      end
      if header["後手"] || header["上手"]
        result += "N-" + (header.delete("後手") || header.delete("上手") || "") + "\n"
      end
      header.each { |(k, v)| result += "$#{csa_header_key(k)}:#{v}\n" }
      result
    end

    def convert_initial(initial)
      result = ""
      data = initial["data"] || {}
      result += if initial["preset"] == "OTHER"
                  convert_board(data["board"])
                else
                  convert_preset(initial["preset"])
                end
      # 持駒
      if data["hands"]
        result += convert_hands(data["hands"], 0)
        result += convert_hands(data["hands"], 1)
      end
      result += csa_color(data["color"]) + "\n" if data["color"]
      result
    end

    def convert_hands(hands, color)
      result = ""
      sum = 0
      hands[color].each_value { |n| sum += n }
      if sum > 0
        result += "P#{csa_color(color)}"
        hands[color].to_a.reverse_each { |(k, v)| v.times { result += "00#{k}" } }
        result += "\n"
      end
      result
    end

    def convert_moves(moves)
      result = ""
      before_pos = nil
      moves.each do |move|
        next if move == {}
        result += convert_move(move["move"], before_pos) if move["move"]
        result += convert_special(move["special"], move["color"]) if move["special"]
        if move["time"]
          result += "," + convert_time(move["time"])
        elsif move["move"] || move["special"]
          result += "\n"
        end
        result += convert_comments(move["comments"]) if move["comments"]
        before_pos = move["move"]["to"] if move["move"] && move["move"]["to"]
      end
      result
    end

    def convert_move(move, before_pos)
      result = csa_color(move["color"])
      result += move["from"] ? pos2str(move["from"]) : "00"
      result += if move["to"]
                  pos2str(move["to"]) + move["piece"]
                else
                  pos2str(before_pos) + move["piece"]
                end
      result
    end

    def convert_special(special, color = nil)
      result = "%"
      result += csa_color(color) if color
      result + special
    end

    def convert_time(time)
      sec = (time["now"]["m"] * 60) + time["now"]["s"]
      "T#{sec}\n"
    end

    def convert_comments(comments)
      comments.map { |comment| "'#{comment}" }.join("\n") + "\n"
    end

    def convert_board(board)
      result = ""
      9.times do |y|
        result += "P#{y + 1}"
        9.times do |x|
          piece = board[8 - x][y]
          result += if piece == {}
                      " * "
                    else
                      csa_color(piece["color"]) + piece["kind"]
                    end
        end
        result += "\n"
      end
      result
    end

    def convert_preset(preset)
      "PI" +
        case preset
        when "HIRATE" # 平手
          ""
        when "KY" # 香落ち
          "11KY"
        when "KY_R" # 右香落ち
          "91KY"
        when "KA" # 角落ち
          "22KA"
        when "HI" # 飛車落ち
          "82HI"
        when "HIKY" # 飛香落ち
          "22HI11KY91KY"
        when "2" # 二枚落ち
          "82HI22KA"
        when "3" # 三枚落ち
          "82HI22KA91KY"
        when "4" # 四枚落ち
          "82HI22KA11KY91KY"
        when "5" # 五枚落ち
          "82HI22KA81KE11KY91KY"
        when "5_L" # 左五枚落ち
          "82HI22KA21KE11KY91KY"
        when "6" # 六枚落ち
          "82HI22KA21KE81KE11KY91KY"
        when "8" # 八枚落ち
          "82HI22KA31GI71GI21KE81KE11KY91KY"
        when "10" # 十枚落ち
          "82HI22KA41KI61KI31GI71GI21KE81KE11KY91KY"
        end
    end

    def csa_color(color)
      color == 0 ? "+" : "-"
    end

    def pos2str(pos)
      "%d%d" % [pos["x"], pos["y"]]
    end

    def version
      "V#{VERSION}\n"
    end

    def csa_header_key(key)
      {
        "棋戦" => "EVENT",
        "場所" => "SITE",
        "開始日時" => "START_TIME",
        "終了日時" => "END_TIME",
        "持ち時間" => "TIME_LIMIT"
      }[key] || key
    end
  end
end
