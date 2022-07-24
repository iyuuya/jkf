# coding: utf-8

module Jkf::Parser
  # CSA Parser
  class Csa < Base
    protected

    # kifu : csa2 | csa1
    def parse_root
      @input += "\n" unless @input[-1] =~ /\n|\r|,/ # FIXME
      s0 = parse_csa2
      s0 = parse_csa1 if s0 == :failed
      s0
    end

    # csa2 : version22 information? initialboard moves?
    def parse_csa2
      s0 = @current_pos
      if parse_version22 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s1 = parse_information
        s1 = nil if s1 == :failed
        s2 = parse_initial_board
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s3 = parse_moves
          s3 = nil if s3 == :failed
          @reported_pos = s0
          s0 = -> (info, ini, ms) do
            ret = { "header" => info["header"], "initial" => ini, "moves" => ms }
            if info && info["players"]
              ret["header"]["先手"] = info["players"][0] if info["players"][0]
              ret["header"]["後手"] = info["players"][1] if info["players"][1]
            end
            ret
          end.call(s1, s2, s3)
        end
      end
      s0
    end

    # version22 : comment* "V2.2" nl
    def parse_version22
      s0 = @current_pos
      s1 = parse_comments
      s2 = match_str("V2.2")
      if s2 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s3 = parse_nl
        if s3 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s0 = [s1, s2, s3]
        end
      end
      s0
    end

    # information : players? headers
    def parse_information
      s0 = @current_pos
      s1 = parse_players
      s1 = nil if s1 == :failed
      s2 = parse_headers
      if s2 == :failed
        @current_pos = s0
        s0 = :failed
      else
        @reported_pos = s0
        s0 = { "players" => s1, "header" => s2 }
      end
      s0
    end

    # headers : header*
    def parse_headers
      s0 = @current_pos
      s1 = []
      s2 = parse_header
      while s2 != :failed
        s1 << s2
        s2 = parse_header
      end
      @reported_pos = s0
      s0 = -> (header) do
        ret = {}
        header.each do |data|
          ret[normalize_header_key(data["k"])] = data["v"]
        end
        ret
      end.call(s1)
      s0
    end

    # header : comment* "$" [^:]+ ":" nonls nl
    def parse_header
      s0 = @current_pos
      parse_comments
      if match_str("$") == :failed
        @current_pos = s0
        s0 = :failed
      else
        s4 = match_regexp(/^[^:]/)
        if s4 == :failed
          s3 = :failed
        else
          s3 = []
          while s4 != :failed
            s3 << s4
            s4 = match_regexp(/^[^:]/)
          end
        end
        if s3 == :failed
          @current_pos = s0
          s0 = :failed
        elsif match_str(":") != :failed
          s4 = parse_nonls
          if parse_nl == :failed
            @current_pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = { "k" => s3.join, "v" => s4.join }
          end
        else
          @current_pos = s0
          s0 = :failed
        end
      end
      s0
    end

    # csa1 : players? initialboard? moves
    def parse_csa1
      s0 = @current_pos
      s1 = parse_players
      s1 = nil if s1 == :failed
      s2 = parse_initial_board
      s2 = nil if s2 == :failed
      s3 = parse_moves
      if s3 == :failed
        @current_pos = s0
        s0 = :failed
      else
        @reported_pos = s0
        s0 = -> (ply, ini, ms) do
          ret = { "header" => {}, "initial" => ini, "moves" => ms }
          if ply
            ret["header"]["先手"] = ply[0] if ply[0]
            ret["header"]["後手"] = ply[1] if ply[1]
          end
          ret
        end.call(s1, s2, s3)
      end
      s0
    end

    # players : comment* ("N+" nonls nl)? comment* ("N-" nonls nl)?
    def parse_players
      s0 = @current_pos
      parse_comments
      s2 = @current_pos
      if match_str("N+") == :failed
        @current_pos = s2
        s2 = :failed
      else
        s4 = parse_nonls
        if parse_nl == :failed
          @current_pos = s2
          s2 = :failed
        else
          @reported_pos = s2
          s2 = s4
        end
      end
      s2 = nil if s2 == :failed
      parse_comments
      s4 = @current_pos
      if match_str("N-") == :failed
        @current_pos = s4
        s4 = :failed
      else
        s6 = parse_nonls
        if parse_nl == :failed
          @current_pos = s4
          s4 = :failed
        else
          @reported_pos = s4
          s4 = s6
        end
      end
      s4 = nil if s4 == :failed
      @reported_pos = s0
      s0 = [(s2 ? s2.join : nil), (s4 ? s4.join : nil)]
      s0
    end

    # initialboard : comment* (hirate | ikkatsu | "") komabetsu comment* teban nl
    def parse_initial_board
      s0 = @current_pos
      parse_comments
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
      if s2 == :failed
        @current_pos = s0
        :failed
      else
        s3 = parse_komabetsu
        if s3 == :failed
          @current_pos = s0
          :failed
        else
          parse_comments
          s5 = parse_teban
          if s5 == :failed
            @current_pos = s0
            :failed
          elsif parse_nl != :failed
            @reported_pos = s0
            -> (data, koma, teban) do
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
            :failed
          end
        end
      end
    end

    # hirate : "PI" xypiece* nl
    def parse_hirate
      s0 = @current_pos
      if match_str("PI") == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = []
        s3 = parse_xy_piece
        while s3 != :failed
          s2 << s3
          s3 = parse_xy_piece
        end
        if parse_nl == :failed
          @current_pos = s0
          s0 = :failed
        else
          @reported_pos = s0
          s0 = -> (ps) do
            ret = { "preset" => "OTHER", "data" => { "board" => get_hirate } }
            ps.each do |piece|
              ret["data"]["board"][piece["xy"]["x"] - 1][piece["xy"]["y"] - 1] = {}
            end
            ret
          end.call(s2)
        end
      end
      s0
    end

    # ikkatsu : ikkatsuline+
    def parse_ikkatsu
      s0 = @current_pos
      s2 = parse_ikkatsu_line
      if s2 == :failed
        s1 = :failed
      else
        s1 = []
        while s2 != :failed
          s1 << s2
          s2 = parse_ikkatsu_line
        end
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

    # ikkatsuline : "P" [1-9] masu+ nl
    def parse_ikkatsu_line
      s0 = @current_pos
      if match_str("P") == :failed
        @current_pos = s0
        s0 = :failed
      elsif match_digit != :failed
        s4 = parse_masu
        if s4 == :failed
          s3 = :failed
        else
          s3 = []
          while s4 != :failed
            s3 << s4
            s4 = parse_masu
          end
        end
        if s3 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s4 = parse_nl
          if s4 == :failed
            @current_pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = s3
          end
        end
      else
        @current_pos = s0
        s0 = :failed
      end
      s0
    end

    # masu : teban piece | " * "
    def parse_masu
      s0 = @current_pos
      s1 = parse_teban
      if s1 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = parse_piece
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        else
          @reported_pos = s0
          s0 = { "color" => s1, "kind" => s2 }
        end
      end
      if s0 == :failed
        s0 = @current_pos
        if match_str(" * ") != :failed
          @reported_pos = s0
          s1 = {}
        end
        s0 = s1
      end
      s0
    end

    # komabetsu : komabetsuline*
    def parse_komabetsu
      s0 = @current_pos
      s1 = []
      s2 = parse_komabetsu_line
      while s2 != :failed
        s1 << s2
        s2 = parse_komabetsu_line
      end
      @reported_pos = s0
      transform_komabetsu_lines(s1)
    end

    # komabetsuline : "P" teban xypiece+ nl
    def parse_komabetsu_line
      s0 = @current_pos
      if match_str("P") == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = parse_teban
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s4 = parse_xy_piece
          if s4 == :failed
            s3 = :failed
          else
            s3 = []
            while s4 != :failed
              s3 << s4
              s4 = parse_xy_piece
            end
          end
          if s3 == :failed
            @current_pos = s0
            s0 = :failed
          elsif parse_nl != :failed
            @reported_pos = s0
            s0 = { "teban" => s2, "pieces" => s3 }
          else
            @current_pos = s0
            s0 = :failed
          end
        end
      end
      s0
    end

    # moves : firstboard move* comment*
    def parse_moves
      s0 = @current_pos
      s1 = parse_firstboard
      if s1 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = []
        s3 = parse_move
        while s3 != :failed
          s2 << s3
          s3 = parse_move
        end
        parse_comments
        @reported_pos = s0
        s0 = s2.unshift(s1)
      end
      s0
    end

    # firstboard : comment*
    def parse_firstboard
      s0 = @current_pos
      s1 = parse_comments
      @reported_pos = s0
      s1.empty? ? {} : { "comments" => s1 }
    end

    # move : (normalmove | specialmove) time? comment*
    def parse_move
      s0 = @current_pos
      s1 = parse_normal_move
      s1 = parse_special_move if s1 == :failed
      if s1 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = parse_time
        s2 = nil if s2 == :failed
        s3 = parse_comments
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
      end
      s0
    end

    # normalmove : teban xy xy piece nl
    def parse_normal_move
      s0 = @current_pos
      s1 = parse_teban
      if s1 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = parse_xy
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s3 = parse_xy
          if s3 == :failed
            @current_pos = s0
            s0 = :failed
          else
            s4 = parse_piece
            if s4 == :failed
              @current_pos = s0
              s0 = :failed
            elsif parse_nl != :failed
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
          end
        end
      end
      s0
    end

    # specialmove : "%" [-+_A-Z]+ nl
    def parse_special_move
      s0 = @current_pos
      s1 = match_str("%")
      if s1 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s3 = match_regexp(/^[\-+_A-Z]/)
        if s3 == :failed
          s2 = :failed
        else
          s2 = []
          while s3 != :failed
            s2 << s3
            s3 = match_regexp(/^[\-+_A-Z]/)
          end
        end
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        elsif parse_nl != :failed
          @reported_pos = s0
          s0 = { "special" => s2.join }
        else
          @current_pos = s0
          s0 = :failed
        end
      end
      s0
    end

    # teban : "+" | "-"
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

    # comment : "'" nonls nl
    def parse_comment
      s0 = @current_pos
      if match_str("'") == :failed
        @current_pos = s0
        :failed
      else
        s2 = parse_nonls
        if parse_nl == :failed
          @current_pos = s0
          :failed
        else
          @reported_pos = s0
          s2.join
        end
      end
    end

    # comments : comment*
    def parse_comments
      stack = []
      matched = parse_comment
      while matched != :failed
        stack << matched
        matched = parse_comment
      end
      stack
    end

    # time : "T" [0-9]* nl
    def parse_time
      s0 = @current_pos
      if match_str("T") == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = match_digits
        if parse_nl == :failed
          @current_pos = s0
          s0 = :failed
        else
          @reported_pos = s0
          s0 = { "now" => sec2time(s2.join.to_i) }
        end
      end
      s0
    end

    # xy : [0-9] [0-9]
    def parse_xy
      s0 = @current_pos
      s1 = match_digit
      if s1 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = match_digit
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        else
          @reported_pos = s0
          s0 = { "x" => s1.to_i, "y" => s2.to_i }
        end
      end
      s0
    end

    # piece : [A-Z] [A-Z]
    def parse_piece
      s0 = @current_pos
      s1 = match_regexp(/^[A-Z]/)
      if s1 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = match_regexp(/^[A-Z]/)
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        else
          @reported_pos = s0
          s0 = s1 + s2
        end
      end
      s0
    end

    # xypiece : xy piece
    def parse_xy_piece
      s0 = @current_pos
      s1 = parse_xy
      if s1 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s2 = parse_piece
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        else
          @reported_pos = s0
          s0 = { "xy" => s1, "piece" => s2 }
        end
      end
      s0
    end

    # nl : ("\r"? "\n") | " "* ","
    def parse_nl
      s0 = @current_pos
      s1 = match_str("\r")
      s1 = nil if s1 == :failed
      s2 = match_str("\n")
      if s2 == :failed
        @current_pos = s0
        s0 = :failed
      else
        s0 = [s1, s2]
      end
      if s0 == :failed
        s0 = @current_pos
        s1 = match_spaces
        s2 = match_str(",")
        if s2 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s0 = [s1, s2]
        end
      end
      s0
    end

    # nonl : [^\r\n]
    def parse_nonl
      match_regexp(/^[^\r\n]/)
    end

    # nonls : nonl*
    def parse_nonls
      stack = []
      matched = parse_nonl
      while matched != :failed
        stack << matched
        matched = parse_nonl
      end
      stack
    end

    # lines to jkf
    def transform_komabetsu_lines(lines)
      board = generate_empty_board
      hands = [
        { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 },
        { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 }
      ]
      all = { "FU" => 18, "KY" => 4, "KE" => 4, "GI" => 4, "KI" => 4, "KA" => 2, "HI" => 2 }

      lines.each do |line|
        line["pieces"].each do |piece|
          xy = piece["xy"]
          if xy["x"] == 0
            if piece["piece"] == "AL"
              hands[line["teban"]] = all
              return { "preset" => "OTHER", "data" => { "board" => board, "hands" => hands } }
            end
            obj = hands[line["teban"]]
            obj[piece["piece"]] += 1
          else
            board[xy["x"] - 1][xy["y"] - 1] = { "color" => line["teban"],
                                                "kind" => piece["piece"] }
          end
          all[piece["piece"]] -= 1 if piece["piece"] != "OU"
        end
      end

      { "preset" => "OTHER", "data" => { "board" => board, "hands" => hands } }
    end

    # return empty board jkf
    def generate_empty_board
      board = []
      9.times do |_i|
        line = []
        9.times do |_j|
          line << {}
        end
        board << line
      end
      board
    end

    # sec to time(m, s)
    def sec2time(sec)
      s = sec % 60
      m = (sec - s) / 60
      { "m" => m, "s" => s }
    end

    # return hirate board jkf
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

    # normalize header key
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
