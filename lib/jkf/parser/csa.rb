# coding: utf-8

module Jkf::Parser
  class Csa < Base
    def parse_root
      @input += "\n" unless @input[-1] =~ /\n|\r|,/ # FIXME
      s0 = parse_csa2
      s0 = parse_csa1 if s0 == :failed
      s0
    end

    def parse_csa2
      s0 = @current_pos
      s1 = parse_version22
      if s1 != :failed
        s2 = parse_information
        s2 = nil if s2 == :failed
        if s2 != :failed
          s3 = parse_initial_board
          if s3 != :failed
            s4 = parse_moves
            s4 = nil if s4 == :failed
            if s4 != :failed
              @reported_pos = s0
              s0 = -> (info, ini, ms) do
                ret = { "header" => info["header"], "initial" => ini, "moves" => ms }
                if info && info["players"]
                  ret["header"]["先手"] = info["players"][0] if info["players"][0]
                  ret["header"]["後手"] = info["players"][1] if info["players"][1]
                end
                ret
              end.call(s2, s3, s4)
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

    def parse_version22
      s0 = @current_pos
      s1 = []
      s2 = parse_comment
      while s2 != :failed
        s1 << s2
        s2 = parse_comment
      end
      if s1 != :failed
        s2 = match_str("V2.2")
        if s2 != :failed
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
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_information
      s0 = @current_pos
      s1 = parse_players
      s1 = nil if s1 == :failed
      if s1 != :failed
        s2 = parse_headers
        if s2 != :failed
          @reported_pos = s0
          s0 = { "players" => s1, "header" => s2 }
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

    def parse_headers
      s0 = @current_pos
      s1 = []
      s2 = parse_header
      while s2 != :failed
        s1 << s2
        s2 = parse_header
      end
      if s1 != :failed
        @reported_pos = s0
        s1 = -> (header) do
          ret = {}
          header.each do |data|
            ret[normalize_header_key(data["k"])] = data["v"]
          end
          ret
        end.call(s1)
      end
      s0 = s1
      s0
    end

    def parse_header
      s0 = @current_pos
      s1 = []
      s2 = parse_comment
      while s2 != :failed
        s1 << s2
        s2 = parse_comment
      end
      if s1 != :failed
        s2 = match_str("$")
        if s2 != :failed
          s3 = []
          s4 = match_regexp(/^[^:]/)
          if s4 != :failed
            while s4 != :failed
              s3 << s4
              s4 = match_regexp(/^[^:]/)
            end
          else
            s3 = :failed
          end
          if s3 != :failed
            s4 = match_str(":")
            if s4 != :failed
              s5 = []
              s6 = parse_nonl
              while s6 != :failed
                s5 << s6
                s6 = parse_nonl
              end
              if s5 != :failed
                s6 = parse_nl
                if s6 != :failed
                  @reported_pos = s0
                  s0 = { "k" => s3.join, "v" => s5.join }
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
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_csa1
      s0 = @current_pos
      s1 = parse_players
      s1 = nil if s1 == :failed
      if s1 != :failed
        s2 = parse_initial_board
        s2 = nil if s2 == :failed
        if s2 != :failed
          s3 = parse_moves
          if s3 != :failed
            @reported_pos = s0
            s0 = -> (ply, ini, ms) do
              ret = { "header" => {}, "initial" => ini, "moves" => ms }
              if ply
                ret["header"]["先手"] = ply[0] if ply[0]
                ret["header"]["後手"] = ply[1] if ply[1]
              end
              ret
            end.call(s1, s2, s3)
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

    def parse_players
      s0 = @current_pos
      s1 = []
      s2 = parse_comment
      while s2 != :failed
        s1 << s2
        s2 = parse_comment
      end
      if s1 != :failed
        s2 = @current_pos
        s3 = match_str("N+")
        if s3 != :failed
          s4 = []
          s5 = parse_nonl
          while s5 != :failed
            s4 << s5
            s5 = parse_nonl
          end
          if s4 != :failed
            s5 = parse_nl
            if s5 != :failed
              @reported_pos = s2
              s2 = s4
            else
              @current_pos = s2
              s2 = :failed
            end
          else
            @current_pos = s2
            s2 = :failed
          end
        else
          @current_pos = s2
          s2 = :failed
        end
        s2 = nil if s2 == :failed
        if s2 != :failed
          s3 = []
          s4 = parse_comment
          while s4 != :failed
            s3 << s4
            s4 = parse_comment
          end
          if s3 != :failed
            s4 = @current_pos
            s5 = match_str("N-")
            if s5 != :failed
              s6 = []
              s7 = parse_nonl
              while s7 != :failed
                s6 << s7
                s7 = parse_nonl
              end
              if s6 != :failed
                s7 = parse_nl
                if s7 != :failed
                  @reported_pos = s4
                  s4 = s6
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
            s4 = nil if s4 == :failed
            if s4 != :failed
              @reported_pos = s0
              s0 = [(s2 ? s2.join : nil), (s4 ? s4.join : nil)]
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

    def parse_initial_board
      s0 = @current_pos
      s1 = []
      s2 = parse_comment
      while s2 != :failed
        s1 << s2
        s2 = parse_comment
      end
      if s1 != :failed
        s2 = parse_hirate
        if s2 == :failed
          s2 = parse_ikkatsu
          if s2 == :failed
            s2 = @current_pos
            s3 = match_str("")
            if s3 != :failed
              @reported_pos = s2
              s3 = "NO"
            end
            s2 = s3
          end
        end
        if s2 != :failed
          s3 = parse_komabetsu
          if s3 != :failed
            s4 = []
            s5 = parse_comment
            while s5 != :failed
              s4 << s5
              s5 = parse_comment
            end
            if s4 != :failed
              s5 = parse_teban
              if s5 != :failed
                s6 = parse_nl
                if s6 != :failed
                  @reported_pos = s0
                  s0 = -> (data, koma, teban) do
                    if data == "NO"
                      data = koma
                    else
                      data["data"]["hands"] = koma["data"]["hands"]
                    end
                    data["data"]["color"] = teban
                    data
                  end.call(s2, s3, s5)
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
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_hirate
      s0 = @current_pos
      s1 = match_str("PI")
      if s1 != :failed
        s2 = []
        s3 = parse_xy_piece
        while s3 != :failed
          s2 << s3
          s3 = parse_xy_piece
        end
        if s2 != :failed
          s3 = parse_nl
          if s3 != :failed
            @reported_pos = s0
            s0 = -> (ps) do
              ret = { "preset" => "OTHER", "data" => { "board" => get_hirate } }
              ps.each do |piece|
                ret["data"]["board"][piece["xy"]["x"] - 1][piece["xy"]["y"] - 1] = {}
              end
              ret
            end.call(s2)
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

    def parse_ikkatsu
      s0 = @current_pos
      s1 = []
      s2 = parse_ikkatsu_line
      if s2 != :failed
        while s2 != :failed
          s1 << s2
          s2 = parse_ikkatsu_line
        end
      else
        s1 = :failed
      end
      if s1 != :failed
        @reported_pos = s0
        s1 = -> (lines) do
          board = []
          9.times do |i|
            line = []
            9.times do |j|
              line << lines[j][8 - i]
            end
            board << line
          end
          { "preset" => "OTHER", "data" => { "board" => board } }
        end.call(s1)
      end
      s0 = s1
      s0
    end

    def parse_ikkatsu_line
      s0 = @current_pos
      s1 = match_str("P")
      if s1 != :failed
        s2 = match_regexp(/^[1-9]/)
        if s2 != :failed
          s3 = []
          s4 = parse_masu
          if s4 != :failed
            while s4 != :failed
              s3 << s4
              s4 = parse_masu
            end
          else
            s3 = :failed
          end
          if s3 != :failed
            s4 = parse_nl
            if s4 != :failed
              @reported_pos = s0
              s0 = s3
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
        s1 = match_str(" * ")
        if s1 != :failed
          @reported_pos = s0
          s1 = {}
        end
        s0 = s1
      end
      s0
    end

    def parse_komabetsu
      s0 = @current_pos
      s1 = []
      s2 = parse_komabetsu_line
      while s2 != :failed
        s1 << s2
        s2 = parse_komabetsu_line
      end
      if s1 != :failed
        @reported_pos = s0
        s1 = -> (lines) do
          board = []
          hands = [
            { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
            { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 }
          ]
          all = { "FU" => 18, "KY" => 4, "KE" => 4, "GI" => 4, "KI" => 4, "KA" => 2, "HI" => 2 }
          9.times do |_i|
            line = []
            9.times do |_j|
              line << {}
            end
            board << line
          end

          lines.each do |line|
            line["pieces"].each do |piece|
              if piece["xy"]["x"] == 0
                if piece["piece"] == "AL"
                  hands[line["teban"]] = all
                  return { "preset" => "OTHER", "data" => { "board" => board, "hands" => hands } }
                end
                obj = hands[line["teban"]]
                obj[piece["piece"]] += 1
              else
                board[piece["xy"]["x"] - 1][piece["xy"]["y"] - 1] = { "color" => line["teban"],
                                                                      "kind" => piece["piece"] }
              end
              all[piece["piece"]] -= 1 if piece["piece"] != "OU"
            end
          end

          { "preset" => "OTHER", "data" => { "board" => board, "hands" => hands } }
        end.call(s1)
      end
      s0 = s1
      s0
    end

    def parse_komabetsu_line
      s0 = @current_pos
      s1 = match_str("P")
      if s1 != :failed
        s2 = parse_teban
        if s2 != :failed
          s3 = []
          s4 = parse_xy_piece
          if s4 != :failed
            while s4 != :failed
              s3 << s4
              s4 = parse_xy_piece
            end
          else
            s3 = :failed
          end
          if s3 != :failed
            s4 = parse_nl
            if s4 != :failed
              @reported_pos = s0
              s0 = { "teban" => s2, "pieces" => s3 }
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
        if s2 != :failed
          s3 = []
          s4 = parse_comment
          while s4 != :failed
            s3 << s4
            s4 = parse_comment
          end
          if s3 != :failed
            @reported_pos = s0
            s0 = s2.unshift(s1)
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

    def parse_firstboard
      s0 = @current_pos
      s1 = []
      s2 = parse_comment
      while s2 != :failed
        s1 << s2
        s2 = parse_comment
      end
      if s1 != :failed
        @reported_pos = s0
        s1 = !s1.empty? ? { "comments" => s1 } : {}
      end
      s0 = s1
      s0
    end

    def parse_move
      s0 = @current_pos
      s1 = parse_normal_move
      s1 = parse_special_move if s1 == :failed
      if s1 != :failed
        s2 = parse_time
        s2 = nil if s2 == :failed
        if s2 != :failed
          s3 = []
          s4 = parse_comment
          while s4 != :failed
            s3 << s4
            s4 = parse_comment
          end
          if s3 != :failed
            @reported_pos = s0
            s0 = -> (move, time, comments) do
              ret = {}
              ret["comments"] = comments if !comments.empty?
              ret["time"] = time if time
              if move["special"]
                ret["special"] = move["special"]
              else
                ret["move"] = move
              end
              ret
            end.call(s1, s2, s3)
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

    def parse_normal_move
      s0 = @current_pos
      s1 = parse_teban
      if s1 != :failed
        s2 = parse_xy
        if s2 != :failed
          s3 = parse_xy
          if s3 != :failed
            s4 = parse_piece
            if s4 != :failed
              s5 = parse_nl
              if s5 != :failed
                @reported_pos = s0
                s0 = -> (color, from, to, piece) do
                  ret = { "color" => color, "to" => to, "piece" => piece }
                  ret["from"] = from if from["x"] != 0
                  ret
                end.call(s1, s2, s3, s4)
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

    def parse_special_move
      s0 = @current_pos
      s1 = match_str("%")
      if s1 != :failed
        s2 = []
        s3 = match_regexp(/^[\-+_A-Z]/)
        if s3 != :failed
          while s3 != :failed
            s2 << s3
            s3 = match_regexp(/^[\-+_A-Z]/)
          end
        else
          s2 = :failed
        end
        if s2 != :failed
          s3 = parse_nl
          if s3 != :failed
            @reported_pos = s0
            s0 = { "special" => s2.join }
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

    def parse_teban
      s0 = @current_pos
      s1 = match_str("+")
      if s1 != :failed
        @reported_pos = s0
        s1 = 0
      end
      s0 = s1
      if s0 == :failed
        s0 = @current_pos
        s1 = match_str("-")
        if s1 != :failed
          @reported_pos = s0
          s1 = 1
        end
        s0 = s1
      end
      s0
    end

    def parse_comment
      s0 = @current_pos
      s1 = match_str("'")
      if s1 != :failed
        s2 = []
        s3 = parse_nonl
        while s3 != :failed
          s2 << s3
          s3 = parse_nonl
        end
        if s2 != :failed
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
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    def parse_time
      s0 = @current_pos
      s1 = match_str("T")
      if s1 != :failed
        s2 = []
        s3 = match_regexp(/^[0-9]/)
        while s3 != :failed
          s2 << s3
          s3 = match_regexp(/^[0-9]/)
        end
        if s2 != :failed
          s3 = parse_nl
          if s3 != :failed
            @reported_pos = s0
            s0 = { "now" => sec2time(s2.join.to_i) }
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

    def parse_xy
      s0 = @current_pos
      s1 = match_regexp(/^[0-9]/)
      if s1 != :failed
        s2 = match_regexp(/^[0-9]/)
        if s2 != :failed
          @reported_pos = s0
          s0 = { "x" => s1.to_i, "y" => s2.to_i }
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

    def parse_piece
      s0 = @current_pos
      s1 = match_regexp(/^[A-Z]/)
      if s1 != :failed
        s2 = match_regexp(/^[A-Z]/)
        if s2 != :failed
          @reported_pos = s0
          s0 = s1 + s2
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

    def parse_xy_piece
      s0 = @current_pos
      s1 = parse_xy
      if s1 != :failed
        s2 = parse_piece
        if s2 != :failed
          @reported_pos = s0
          s0 = { "xy" => s1, "piece" => s2 }
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

    def parse_nl
      s0 = @current_pos
      s1 = match_str("\r")
      s1 = nil if s1 == :failed
      if s1 != :failed
        s2 = match_str("\n")
        if s2 != :failed
          s0 = s1 = [s1, s2]
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
        s1 = []
        s2 = match_str(" ")
        while s2 != :failed
          s1 << s2
          s2 = match_str(" ")
        end
        if s1 != :failed
          s2 = match_str(",")
          if s2 != :failed
            s0 = [s1, s2]
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

    def parse_nonl
      match_regexp(/^[^\r\n]/)
    end

    protected

    def sec2time(sec)
      s = sec % 60
      m = (sec - s) / 60
      { "m" => m, "s" => s }
    end

    def get_hirate
      [
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
         { "color" => 0, "kind" => "FU" }, {}, { "color" => 0, "kind" => "KY" }]
      ]
    end

    def normalize_header_key(key)
      {
        "EVENT" => "棋戦",
        "SITE" => "場所",
        "START_TIME" => "開始日時",
        "END_TIME" => "終了日時",
        "TIME_LIMIT" => "持ち時間"
      }[key] || key
    end
  end
end
