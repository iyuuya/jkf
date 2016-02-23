module Jkf::Converter
  module Kifuable
    protected

    def convert_initial(initial)
      result = convert_handicap(initial["preset"])
      footer = ""

      data = initial["data"]
      if data
        result += convert_teban(data, 1)
        if hands = data["hands"]
          result += convert_hands(hands, 1) if hands[1]
          footer += convert_hands(hands, 0) if hands[0]
        end
        footer += convert_teban(data, 0)

        result += convert_board(data["board"]) if data["board"]
      end
      result + footer
    end

    def convert_handicap(preset)
      preset != "OTHER" ? "手合割：#{preset2str(preset)}\n" : ""
    end

    def convert_teban(data, color)
      data["color"] == color ? "#{@players[color]}手番\n" : ""
    end

    def convert_hands(hands, color)
      "#{@players[color]}手の持駒：" + convert_motigoma(hands[color])
    end

    def convert_board(board)
      result = "  ９ ８ ７ ６ ５ ４ ３ ２ １\n+---------------------------+\n"
      9.times do |y|
        line = "|"
        9.times do |x|
          line += convert_board_piece(board[8 - x][y])
        end
        line += "|#{n2kan(y + 1)}\n"
        result += line
      end
      result + "+---------------------------+\n"
    end

    def convert_comments(comments)
      comments.map { |comment| "*#{comment}\n" }.join
    end

    def convert_motigoma(pieces)
      pieces.to_a.reverse.map do |(piece, num)|
        if num > 0
          str = csa2kind(piece)
          if num > 1
            str += n2kan(num / 10) if num / 10 > 0
            num %= 10
            str += n2kan(num)
          end
          str
        end
      end.compact.join("　") + "　\n"
    end

    def convert_board_piece(piece)
      result = ""

      if piece == {}
        result = " ・"
      else
        result += piece["color"] == 0 ? " " : "v"
        result += csa2kind(piece["kind"])
      end

      result
    end

    def convert_special(special, index)
      result = "まで#{index + 1}手"

      if special == "TORYO" || special =~ /ILLEGAL/
        turn = @players[index % 2]
        result += "で#{turn}手の"
        result += case special
                  when "TORYO" then "勝ち"
                  when "ILLEGAL_ACTION" then "反則勝ち"
                  when "ILLEGAL_MOVE" then "反則負け"
                  end
      else
        turn = @players[(index + 1) % 2]
        result += case special
                  when "TIME_UP" then "で時間切れにより#{turn}手の勝ち"
                  when "CHUDAN" then "で中断"
                  when "JISHOGI" then "で持将棋"
                  when "SENNICHITE" then "で千日手"
                  when "TSUMI" then "で詰み"
                  when "FUZUMI" then "で不詰"
                  end
      end

      result + "\n"
    end

    def convert_piece_with_pos(move)
      result = if move["to"]
                 n2zen(move["to"]["x"]) + n2kan(move["to"]["y"])
               elsif move["same"]
                 "同　"
               else
                 raise "error??"
               end
      result += csa2kind(move["piece"])
      result += "成" if move["promote"]
      result
    end

    def convert_forks(forks, index)
      result = "\n"
      result = "変化：%4d手\n" % [index] # ki2の場合\nなし
      forks.each do |moves|
        result += convert_moves(moves, index)
      end
      result
    end

    def reset!
      @forks = []
      @header2 = []
    end

    def setup_players!(jkf)
      players_flag = :sengo
      jkf["header"] && jkf["header"].keys.detect { |key| key =~ /[上下]手/ } && players_flag = :uwasimo
      @players = if players_flag == :uwasimo
                   ["下", "上"]
                 else
                   ["先", "後"]
                 end
    end

    def n2zen(n)
      "０１２３４５６７８９"[n]
    end

    def n2kan(n)
      "〇一二三四五六七八九"[n]
    end

    def csa2kind(csa)
      {
        "FU" => "歩",
        "KY" => "香",
        "KE" => "桂",
        "GI" => "銀",
        "KI" => "金",
        "KA" => "角",
        "HI" => "飛",
        "OU" => "玉",
        "TO" => "と",
        "NY" => "成香",
        "NK" => "成桂",
        "NG" => "成銀",
        "UM" => "馬",
        "RY" => "龍",
      }[csa]
    end

    def preset2str(preset)
      {
        "HIRATE" => "平手",
        "KY" => "香落ち",
        "KY_R" => "右香落ち",
        "KA" => "角落ち",
        "HI" => "飛車落ち",
        "HIKY" => "飛香落ち",
        "2" => "二枚落ち",
        "3" => "三枚落ち",
        "4" => "四枚落ち",
        "5" => "五枚落ち",
        "5_L" => "左五枚落ち",
        "6" => "六枚落ち",
        "8" => "八枚落ち",
        "10" => "十枚落ち",
        "OTHER" => "その他"
      }[preset]
    end
  end
end
