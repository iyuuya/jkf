# coding: utf-8

module Jkf::Parser
  class Ki2 < Base
    def parse_root
      s0 = @current_pos
      s1 = []
      s2 = parse_header
      while s2 != :failed
        s1 << s2
        s2 = parse_header
      end
      if s1 != :failed
        s2 = parse_initialboard
        s2 = nil if s2 == :failed
        s3 = []
        s4 = parse_header
        while s4 != :failed
          s3 << s4
          s4 = parse_header
        end
        s4 = parse_moves
        if s4 != :failed
          s5 = []
          s6 = parse_fork
          while s6 != :failed
            s5 << s6
            s6 = parse_fork
          end
          @reported_pos = s0
          s0 = transform_root(s1, s2, s3, s4, s5)
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_header
      s0 = @current_pos
      s2 = match_regexp(/^[^*：\r\n]/)
      if s2 != :failed
        s1 = []
        while s2 != :failed
          s1 << s2
          s2 = match_regexp(/^[^：\r\n]/)
        end
      else
        s1 = :failed
      end
      if s1 != :failed
        if match_str("：") != :failed
          s3 = []
          s4 = parse_nonl
          while s4 != :failed
            s3 << s4
            s4 = parse_nonl
          end
          s5 = parse_nl
          if s5 != :failed
            s4 = []
            while s5 != :failed
              s4 << s5
              s5 = parse_nl
            end
          else
            s4 = :failed
          end
          if s4 != :failed
            @reported_pos = s0
            s0 = { "k" => s1.join, "v" => s3.join }
          else
            @current_pos = s0
            s0 = :failed
          end
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      if s0 == :failed
        s0 = @current_pos
        s1 = match_regexp(/^[先後上下]/)
        if s1 != :failed
          s2 = match_str("手番")
          if s2 != :failed
            s3 = parse_nl
            if s3 != :failed
              @reported_pos = s0
              s0 = { "k" => "手番", "v" => s1 }
            else
              @current_pos = s0
              s0 = :failed
            end
          else
            @current_pos = s0
            s0 = :failed
          end
        else
          @current_pos = s0
          s0 = :failed
        end
      end
      s0
    end

    def parse_initialboard
      s0 = s1 = @current_pos
      s2 = match_space
      if s2 != :failed
        s3 = []
        s4 = parse_nonl
        while s4 != :failed
          s3 << s4
          s4 = parse_nonl
        end
        s4 = parse_nl
        if s4 != :failed
          s1 = [s2, s3, s4]
        else
          @current_pos = s1
        end
      else
        @current_pos = s1
      end
      s2 = @current_pos
      s3 = match_str("+")
      if s3 != :failed
        s4 = []
        s5 = parse_nonl
        while s5 != :failed
          s4 << s5
          s5 = parse_nonl
        end
        @current_pos = s2 if parse_nl == :failed
      else
        @current_pos = s2
      end
      s4 = parse_ikkatsuline
      if s4 != :failed
        s3 = []
        while s4 != :failed
          s3 << s4
          s4 = parse_ikkatsuline
        end
      else
        s3 = :failed
      end
      if s3 != :failed
        s4 = @current_pos
        if match_str("+") != :failed
          s6 = []
          s7 = parse_nonl
          while s7 != :failed
            s6 << s7
            s7 = parse_nonl
          end
          @current_pos = s4 if parse_nl == :failed
        else
          @current_pos = s4
        end
        @reported_pos = s0
        s0 = -> (lines) do
          board = []
          9.times do |i|
            line = []
            9.times do |j|
              line << lines[j][8 - i]
            end
            board << line
          end
          { "preset" => "OTHER", "data" => { "board" => board } }
        end.call(s3)
      else
        @current_pos = s0
        s0 = :failed
      end

      s0
    end

    def parse_ikkatsuline
      s0 = @current_pos
      if match_str("|") != :failed
        s3 = parse_masu
        if s3 != :failed
          s2 = []
          while s3 != :failed
            s2 << s3
            s3 = parse_masu
          end
        else
          s2 = :failed
        end
        if s2 != :failed
          if match_str("|") != :failed
            s5 = parse_nonl
            if s5 != :failed
              s4 = []
              while s5 != :failed
                s4 << s5
                s5 = parse_nonl
              end
            else
              s4 = :failed
            end
            if s4 != :failed
              if parse_nl != :failed
                @reported_pos = s0
                s0 = s2
              else
                @current_pos = s0
                s0 = :failed
              end
            else
              @current_pos = s0
              s0 = :failed
            end
          else
            @current_pos = s0
            s0 = :failed
          end
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end

      s0
    end

    def parse_masu
      s0 = @current_pos
      s1 = parse_teban
      if s1 != :failed
        s2 = parse_piece
        if s2 != :failed
          @reported_pos = s0
          s0 = { "color" => s1, "kind" => s2 }
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      if s0 == :failed
        s0 = @current_pos
        s1 = match_str(" ・")
        if s1 != :failed
          @reported_pos = s0
          s1 = {}
        end
        s0 = s1
      end

      s0
    end

    def parse_teban
      s0 = @current_pos
      s1 = match_space
      s1 = match_str("+") if s1 == :failed
      s1 = match_str("^") if s1 == :failed
      if s1 != :failed
        @reported_pos = s0
        s1 = 0
      end
      s0 = s1
      if s0 == :failed
        s0 = @current_pos
        s1 = match_str("v")
        s1 = match_str("V") if s1 == :failed
        if s1 != :failed
          @reported_pos = s0
          s1 = 1
        end
        s0 = s1
      end
      s0
    end

    def parse_moves
      s0 = @current_pos
      s1 = parse_firstboard
      if s1 != :failed
        s2 = []
        s3 = parse_move
        while s3 != :failed
          s2 << s3
          s3 = parse_move
        end
        s3 = parse_result
        s3 = nil if s3 == :failed
        @reported_pos = s0
        s0 = -> (hd, tl, res) do
          tl.unshift(hd)
          tl << { "special" => res } if res && !tl[tl.length - 1]["special"]
          tl
        end.call(s1, s2, s3)
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_firstboard
      s0 = @current_pos
      s1 = []
      s2 = parse_comment
      while s2 != :failed
        s1 << s2
        s2 = parse_comment
      end
      parse_pointer
      @reported_pos = s0
      s0 = s1.empty? ? {} : { "comments" => s1 }
      s0
    end

    def parse_move
      s0 = @current_pos
      s1 = parse_line
      if s1 != :failed
        s2 = []
        s3 = parse_comment
        while s3 != :failed
          s2 << s3
          s3 = parse_comment
        end
        parse_pointer
        s4 = []
        s5 = parse_nl
        s5 = match_space if s5 == :failed
        while s5 != :failed
          s4 << s5
          s5 = parse_nl
          s5 = match_space if s5 == :failed
        end
        @reported_pos = s0
        s0 = -> (line, c) do
          ret = { "move" => line }
          ret["comments"] = c if !c.empty?
          ret
        end.call(s1, s2)
      else
        @current_pos = s0
        s0 = :failed
      end

      s0
    end

    def parse_pointer
      s0 = @current_pos
      s1 = match_str("&")
      if s1 != :failed
        s2 = []
        s3 = parse_nonl
        while s3 != :failed
          s2 << s3
          s3 = parse_nonl
        end
        s3 = parse_nl
        if s3 != :failed
          s0 = [s1, s2, s3]
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_line
      s0 = @current_pos
      s1 = match_regexp(/^[▲△]/)
      if s1 != :failed
        s1 = if s1 == "▲"
               { "color" => 0 }
             else
               { "color" => 1 }
             end
        s2 = parse_fugou
        if s2 != :failed
          s3 = []
          s4 = parse_nl
          s4 = match_space if s4 == :failed
          while s4 != :failed
            s3 << s4
            s4 = parse_nl
            s4 = match_space if s4 == :failed
          end
          @reported_pos = s0
          s0 = s2.merge(s1)
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_fugou
      s0 = @current_pos
      s1 = parse_place
      if s1 != :failed
        s2 = parse_piece
        if s2 != :failed
          s3 = parse_soutai
          s3 = nil if s3 == :failed
          s4 = parse_dousa
          s4 = nil if s4 == :failed
          s5 = match_str("成")
          s5 = match_str("不成") if s5 == :failed
          s5 = nil if s5 == :failed
          s6 = match_str("打")
          s6 = nil if s6 == :failed
          @reported_pos = s0
          s0 = -> (pl, pi, sou, dou, pro, da) do
            ret = { "piece" => pi }
            if pl["same"]
              ret["same"] = true
            else
              ret["to"] = pl
            end
            ret["promote"] = (pro == "成") if pro
            if da
              ret["relative"] = "H"
            else
              rel = soutai2relative(sou) + dousa2relative(dou)
              ret["relative"] = rel unless rel.empty?
            end
            ret
          end.call(s1, s2, s3, s4, s5, s6)
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_place
      s0 = @current_pos
      s1 = parse_num
      if s1 != :failed
        s2 = parse_numkan
        if s2 != :failed
          @reported_pos = s0
          s0 = { "x" => s1, "y" => s2 }
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      if s0 == :failed
        s0 = @current_pos
        if match_regexp("同") != :failed
          match_str("　")
          @reported_pos = s0
          s0 = { "same" => true }
        else
          @current_pos = s0
          s0 = :failed
        end
      end
      s0
    end

    def parse_piece
      s0 = @current_pos
      s1 = match_regexp("成")
      s1 = "" if s1 == :failed
      s2 = match_regexp(/^[歩香桂銀金角飛王玉と杏圭全馬竜龍]/)
      if s2 != :failed
        @reported_pos = s0
        s0 = kind2csa(s1 + s2)
      else
        @current_pos = s0
        s0 = :failed
      end

      s0
    end

    def parse_soutai
      match_regexp(/^[左直右]/)
    end

    def parse_dousa
      match_regexp(/^[上寄引]/)
    end

    def parse_num
      s0 = @current_pos
      s1 = match_regexp(/^[１２３４５６７８９]/)
      if s1 != :failed
        @reported_pos = s0
        s1 = zen2n(s1)
      end
      s0 = s1
      s0
    end

    def parse_numkan
      s0 = @current_pos
      s1 = match_regexp(/^[一二三四五六七八九]/)
      if s1 != :failed
        @reported_pos = s0
        s1 = kan2n(s1)
      end
      s0 = s1
      s0
    end

    def parse_comment
      s0 = @current_pos
      if match_str("*") != :failed
        s2 = []
        s3 = parse_nonl
        while s3 != :failed
          s2 << s3
          s3 = parse_nonl
        end
        s3 = parse_nl
        if s3 != :failed
          @reported_pos = s0
          s0 = s2.join
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_result
      s0 = @current_pos
      if match_str("まで") != :failed
        s2 = match_digits!
        if s2 != :failed
          if match_str("手") != :failed
            s4 = @current_pos
            if match_str("で") != :failed
              if parse_turn != :failed
                if match_str("手の") != :failed
                  s8 = @current_pos
                  s9 = match_str("勝ち")
                  if s9 != :failed
                    @reported_pos = s8
                    s9 = "TORYO"
                  end
                  s8 = s9
                  s8 = parse_result_illegal if s8 == :failed
                  s4 = if s8 != :failed
                         @reported_pos = s4
                         s8
                       else
                         @current_pos = s4
                         :failed
                       end
                else
                  @current_pos = s4
                  s4 = :failed
                end
              else
                @current_pos = s4
                s4 = :failed
              end
            else
              @current_pos = s4
              s4 = :failed
            end
            if s4 == :failed
              s4 = @current_pos
              s4 = if match_str("で時間切れにより") != :failed
                     if parse_turn != :failed
                       if match_str("手の勝ち") != :failed
                         @reported_pos = s4
                         "TIME_UP"
                       else
                         @current_pos = s4
                         :failed
                       end
                     else
                       @current_pos = s4
                       :failed
                     end
                   else
                     @current_pos = s4
                     :failed
                   end
              if s4 == :failed
                s4 = @current_pos
                s5 = match_str("で中断")
                if s5 != :failed
                  @reported_pos = s4
                  s5 = "CHUDAN"
                end
                s4 = s5
                if s4 == :failed
                  s4 = @current_pos
                  s5 = match_str("で持将棋")
                  if s5 != :failed
                    @reported_pos = s4
                    s5 = "JISHOGI"
                  end
                  s4 = s5
                  if s4 == :failed
                    s4 = @current_pos
                    s5 = match_str("で千日手")
                    if s5 != :failed
                      @reported_pos = s4
                      s5 = "SENNICHITE"
                    end
                    s4 = s5
                    if s4 == :failed
                      s4 = @current_pos
                      match_str("で")
                      s4 = if match_str("詰") != :failed
                             match_str("み")
                             @reported_pos = s4
                             "TSUMI"
                           else
                             @current_pos = s4
                             :failed
                           end
                      if s4 == :failed
                        s4 = @current_pos
                        s5 = match_str("で不詰")
                        if s5 != :failed
                          @reported_pos = s4
                          s5 = "FUZUMI"
                        end
                        s4 = s5
                      end
                    end
                  end
                end
              end
            end
            if s4 != :failed
              if parse_nl != :failed || @input[@current_pos].nil?
                @reported_pos = s0
                s4
              else
                @current_pos = s0
                :failed
              end
            else
              @current_pos = s0
              :failed
            end
          else
            @current_pos = s0
            :failed
          end
        else
          @current_pos = s0
          :failed
        end
      else
        @current_pos = s0
        :failed
      end
    end

    def parse_result_illegal
      s0 = @current_pos
      if match_str("反則") != :failed
        s10 = @current_pos
        s11 = match_str("勝ち")
        if s11 != :failed
          @reported_pos = s10
          s11 = "ILLEGAL_ACTION"
        end
        s10 = s11
        if s10 == :failed
          s10 = @current_pos
          s11 = match_str("負け")
          if s11 != :failed
            @reported_pos = s10
            s11 = "ILLEGAL_MOVE"
          end
          s10 = s11
        end
        if s10 != :failed
          @reported_pos = s0
          s10
        else
          @current_pos = s0
          :failed
        end
      else
        @current_pos = s0
        :failed
      end
    end

    def parse_fork
      s0 = @current_pos
      if match_str("変化：") != :failed
        match_spaces
        s3 = match_digits!
        if s3 != :failed
          if match_str("手") != :failed
            if parse_nl != :failed
              s6 = parse_moves
              if s6 != :failed
                @reported_pos = s0
                s0 = { "te" => s3.join.to_i, "moves" => s6[1..-1] }
              else
                @current_pos = s0
                s0 = :failed
              end
            else
              @current_pos = s0
              s0 = :failed
            end
          else
            @current_pos = s0
            s0 = :failed
          end
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_turn
      match_regexp(/^[先後上下]/)
    end

    def parse_nl
      s0 = @current_pos
      s2 = parse_newline
      if s2 != :failed
        s1 = []
        while s2 != :failed
          s1 << s2
          s2 = parse_newline
        end
      else
        s1 = :failed
      end
      if s1 != :failed
        s2 = []
        s3 = parse_skipline
        while s3 != :failed
          s2 << s3
          s3 = parse_skipline
        end
        s0 = [s1, s2]
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_skipline
      s0 = @current_pos
      s1 = match_str("#")
      if s1 != :failed
        s2 = []
        s3 = parse_nonl
        while s3 != :failed
          s2 << s3
          s3 = parse_nonl
        end
        s3 = parse_newline
        if s3 != :failed
          s0 = [s1, s2, s3]
        else
          @current_pos = s0
          s0 = :failed
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_whitespace
      s0 = match_space
      s0 = match_str("\t") if s0 == :failed
      s0
    end

    def parse_newline
      s0 = @current_pos
      s1 = []
      s2 = parse_whitespace
      while s2 != :failed
        s1 << s2
        s2 = parse_whitespace
      end
      s2 = match_str("\n")
      if s2 == :failed
        s2 = @current_pos
        s3 = match_str("\r")
        if s3 != :failed
          s4 = match_str("\n")
          s4 = nil if s4 == :failed
          s2 = [s3, s4]
        else
          @current_pos = s2
          s2 = :failed
        end
      end
      if s2 != :failed
        s0 = [s1, s2]
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_nonl
      match_regexp(/^[^\r\n]/)
    end

    protected

    def transform_root(headers, ini, headers2, moves, forks)
      ret = { "header" => {}, "moves" => moves }
      headers.compact.each { |h| ret["header"][h["k"]] = h["v"] }
      headers2.compact.each { |h| ret["header"][h["k"]] = h["v"] }
      if ini
        ret["initial"] = ini
      elsif ret["header"]["手合割"]
        preset = preset2str(ret["header"]["手合割"])
        ret["initial"] = { "preset" => preset } if preset != "OTHER"
      end
      if ret["initial"] && ret["initial"]["data"]
        if ret["header"]["手番"]
          ret["initial"]["data"]["color"] = "下先".index(ret["header"]["手番"]) >= 0 ? 0 : 1
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
      ret
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

    def soutai2relative(str)
      {
        "左" => "L",
        "直" => "C",
        "右" => "R"
      }[str] || ""
    end

    def dousa2relative(str)
      {
        "上" => "U",
        "寄" => "M",
        "引" => "D"
      }[str] || ""
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

    def make_hand(str)
      ret = { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 }
      return ret if str.empty?

      str.gsub(/　$/, "").split("　").each do |kind|
        next if kind.empty?
        ret[kind2csa(kind[0])] = kind.length == 1 ? 1 : kan2n2(kind[1..-1])
      end

      ret
    end
  end
end
