module Jkf::Converter
  class Kif < Base
    protected

    include Kifuable

    def convert_root(jkf)
      reset!
      setup_players!(jkf)

      result = ""
      result += convert_header(jkf["header"]) if jkf["header"]
      result += convert_initial(jkf["initial"]) if jkf["initial"]
      result += @header2.join
      result += "手数----指手---------消費時間--\n"
      result += convert_moves(jkf["moves"])
      if !@forks.empty?
        result += "\n"
        result += @forks.join("\n")
      end

      result
    end

    def convert_header(header)
      header.map do |(key, value)|
        result = "#{key}：#{value}\n"
        if key =~ /\A[先後上下]手\Z/
          if key =~ /[先下]/
            @header2.unshift result
          else
            @header2 << result
          end
          nil
        else
          result
        end
      end.compact.join
    end

    def convert_moves(moves, idx = 0)
      result = ""
      moves.each_with_index do |move, i|
        if move["special"]
          result += convert_special_line(move, i + idx)
        else
          result += convert_move_line(move, i + idx) if move["move"]
          result += convert_comments(move["comments"]) if move["comments"]
          @forks.unshift convert_forks(move["forks"], i + idx) if move["forks"]
        end
      end
      result
    end

    def convert_move_line(move, index)
      result = "%4d " % [index]
      result += convert_move(move["move"])
      result += convert_time(move["time"]) if move["time"]
      result += "+" if move["forks"]
      result + "\n"
    end

    def convert_special_line(move, index)
      result = "%4d " % [index]
      result += ljust(special2kan(move["special"]), 13)
      result += convert_time(move["time"]) if move["time"]
      result += "+" if move["forks"]
      result += "\n"
      # first_board+speical分を引く(-2)
      result + convert_special(move["special"], index - 2)
    end

    def convert_move(move)
      result = convert_piece_with_pos(move)
      result += if move["from"]
                  "(#{pos2str(move['from'])})"
                else
                  "打"
                end
      ljust(result, 13)
    end

    def convert_time(time)
      "(%2d:%02d/%02d:%02d:%02d)" % [
        time["now"]["m"],
        time["now"]["s"],
        time["total"]["h"],
        time["total"]["m"],
        time["total"]["s"]
      ]
    end

    def special2kan(special)
      case special
      when "CHUDAN" then "中断"
      when "TORYO" then "投了"
      when "JISHOGI" then "持将棋"
      when "SENNICHITE" then "千日手"
      when "TSUMI" then "詰み"
      when "FUZUMI" then "不詰"
      when "TIME_UP" then "切れ負け"
      when "ILLEGAL_ACTION" then "反則勝ち"
      when "ILLEGAL_MOVE" then "反則負け"
      end
    end

    def ljust(str, n)
      len = 0
      str.each_codepoint { |codepoint| len += codepoint > 255 ? 2 : 1 }
      str + " " * (n - len)
    end

    def pos2str(pos)
      "%d%d" % [pos["x"], pos["y"]]
    end
  end
end
