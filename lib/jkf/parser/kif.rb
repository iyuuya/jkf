# coding: utf-8

module Jkf::Parser
  class Kif
    def parse(input)
      @input = input.clone

      @current_pos        = 0
      @reported_pos       = 0
      @cached_pos         = 0
      @cached_pos_details = { line: 1, column: 1, seenCR: false }
      @max_fail_pos       = 0
      @max_fail_expected  = []
      @silent_fails       = 0

      @result = parse_kifu

      if @result != @failded && @current_pos == @input.length
        return @result
      else
        fail({ type: "end", description: "end of input" }) if @result != :failed && @current_pos < input.length
        raise SyntaxError
      end
    end

    def parse_kifu
      s0 = @current_pos
      s1 = []
      s2 = parse_skipline
      while s2 != :failed
        s1 << s2
        s2 = parse_skipline
      end
      if s1 != :failed
        s2 = []
        s3 = parse_header
        while s3 != :failed
          s2 << s3
          s3 = parse_header
        end
        if s2 != :failed
          s3 = parse_initial_board
          s3 = nil if s3 == :failed
          if s3 != :failed
            s4 = []
            s5 = parse_header
            while s5 != :failed
              s4 << s5
              s5 = parse_header
            end
            if s4 != :failed
              s5 = parse_split
              s5 = nil if s5 == :failed
              if s5 != :failed
                s6 = parse_moves
                if s6 != :failed
                  s7 = []
                  s8 = parse_fork
                  while s8 != :failed
                    s7 << s8
                    s8 = parse_fork
                  end
                  if s7 != :failed
                    s8 = parse_nl
                    s8 = nil if s8 == :failed
                    if s8 != :failed
                      @reported_pos = s0
                      s1 = -> (headers, ini, headers2, moves, forks) {
                        ret = { header: {}, moves: moves }
                        headers.each { |h| ret[:header][h[:k]] = h[:v] }
                        headers2.each { |h| ret[:header][h[:k]] = h[:v] }
                        if ini
                          ret[:initial] = ini
                        elsif ret[:header]["手合割"]
                          preset = preset2str(ret[:header]["手合割"])
                          ret[:initial] = { preset: preset } if preset && preset != "OTHER"
                        end
                        if ret[:initial] && ret[:initial][:data]
                          if ret[:header]["手番"]
                            ret[:initial][:data][:color] = ("下先".index(ret[:header]["手番"]) >= 0 ? 0 : 1)
                            ret[:header].delete("手番")
                          else
                            ret[:initial][:data][:color] = 0
                          end
                          ret[:initial][:data][:hand] = [
                            make_hand(ret[:header]["先手の持駒"] || ret[:header]["下手の持駒"]),
                            make_hand(ret[:header]["後手の持駒"] || ret[:header]["上手の持駒"])
                          ]
                          %w(先手の持駒 下手の持駒 後手の持駒 上手の持駒).each do |key|
                            ret[:header].delete(key)
                          end
                        end
                        fork_stack = [{ te: 0, moves: moves }]
                        forks.each do |f|
                          now_fork = f
                          _fork = fork_stack.pop()
                          _fork = fork_stack.pop while _fork[:te] > now_fork[:te]
                          move = _fork[:moves][now_fork[:te] - _fork[:te]]
                          move[:forks] ||= []
                          move[:forks] << now_fork[:moves]
                          fork_stack << _fork
                          fork_stack << now_fork
                        end
                        ret
                      }.call(s2, s3, s4, s6, s7)
                      s0 = s1
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
      s1 = []
      s2 = match_regexp(/^[^：\r\n]/)
      if s2 != :failed
        while s2 != :failed
          s1 << s2
          s2 = match_regexp(/^[^：\r\n]/)
        end
      else
        s1 = :failed
      end
      if s1 != :failed
        s2 = match_str("：")
        if s2 != :failed
          s3 = []
          s4 = parse_nonl
          while s4 != :failed
            s3 << s4
            s4 = parse_nonl
          end
          if s3 != :failed
            s4 = parse_nl
            if s4 != :failed
              @reported_pos = s0
              s1 = { k: s1.join, v: s3.join }
              s0 = s1
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
      if s0 == :failed
        s0 = @current_pos
        s1 = parse_turn
        if s1 != :failed
          s2 = match_str("手番")
          if s2 != :failed
            s3 = parse_nl
            if s3 != :failed
              @reported_pos = s0
              s0 = s1 = { k: "手番", v: s1 }
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
          s1 = match_str("盤面回転")
          if s1 != :failed
            s2 = parse_nl
            if s2 != :failed
              @reported_pos = s0
              s0 = s1 = nil
            else
              @current_pos = s0
              s0 = :failed
            end
          else
            @current_pos = s0
            s0 = :failed
          end
        end
      end

      s0
    end

    def parse_turn
      match_regexp(/[先後上下]/)
    end

    def parse_initial_board
      s0 = s1 = @current_pos
      s2 = match_str(" ")
      if s2 != :failed
        s3 = []
        s4 = parse_nonl
        while s4 != :failed
          s3 << s4
          s4 = parse_nonl
        end
        if s3 != :failed
          s4 = parse_nl
          if s4 != :failed
            s1 = s2 = [s2, s3, s4]
          else
            @current_pos = s1
            s1 = :failed
          end
        else
          @current_pos = s1
          s1 = :failed
        end
      else
        @current_pos = s1
        s1 = :failed
      end
      if s1 == :failed
        s1 = nil
      end
      if s1 != :failed
        s2 = @current_pos
        s3 = match_str("+")
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
              s2 = s3 = [s3, s4, s5]
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
          s4 = parse_ikkatsu_line
          if s4 != :failed
            while s4 != :failed
              s3 << s4
              s4 = parse_ikkatsu_line
            end
          else
            s3 = :failed
          end
          if s3 != :failed
            s4 = @current_pos
            s5 = match_str("+")
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
                  s4 = s5 = [s5, s6, s7]
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
              s1 = -> (lines) {
                ret = [];
                9.times { |i|
                  line = [];
                  9.times { |j|
                    line << lines[j][8-i]
                  }
                  ret << line
                }
                { preset: "OTHER", data: { board: ret } }
              }.call(s3)
              s0 = s1
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

    def parse_ikkatsu_line
      s0 = @current_pos
      s1 = match_str("|")
      if s1 != :failed
        s2 = []
        s3 = parse_masu
        if s3 != :failed
          while s3 != :failed
            s2 << s3
            s3 = parse_masu
          end
        else
          s2 = :failed
        end
        if s2 != :failed
          s3 = match_str("|")
          if s3 != :failed
            s4 = []
            s5 = parse_nonl
            if s5 != :failed
              while s5 != :failed
                s4 << s5
                s5 = parse_nonl
              end
            else
              s4 = :failed
            end
            if s4 != :failed
              s5 = parse_nl
              if s5 != :failed
                @reported_pos = s0
                s0 = s1 = s2
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
          s0 = s1 = { color: s1, kind: s2 }
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
      s1 = match_str(" ")
      if s1 == :failed
        s1 = match_str("+")
        s1 = match_str("^") if s1 == :failed
      end
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

    def parse_split
      s0 = @current_pos
      s1 = match_str("手数----指手--")
      if s1 != :failed
        s2 = match_str("-------消費時間--")
        s2 = nil if s2 == :failed
        if s2 != :failed
          s3 = parse_nl
          if s3 != :failed
            s0 = s1 = [s1, s2, s3]
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
        s2 = parse_split
        s2 = nil if s2 == :failed
        if s2 != :failed
          s3 = []
          s4 = parse_move
          while s4 != :failed
            s3 << s4
            s4 = parse_move
          end
          if s3 != :failed
            s4 = parse_result
            s4 = nil if s4 == :failed
            if s4 != :failed
              @reported_pos = s0
              s0 = s1 = s3.unshift(s1)
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

    def parse_firstboard
      s0 = @current_pos
      s1 = []
      s2 = parse_comment
      while s2 != :failed
        s1 << s2
        s2 = parse_comment
      end
      if s1 != :failed
        s2 = parse_pointer
        if s2 == :failed
          s2 = nil
        end
        if s2 != :failed
          @reported_pos = s0
          s0 = s1 = s1.length == 0 ? {} : { comments: s1 }
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
        if s2 != :failed
          s3 = parse_pointer
          s3 = nil if s3 == :failed
          if s3 != :failed
            @reported_pos = s0
            s1 = -> (line, c) {
              ret = {}
              ret[:comments] = c if c.length > 0
              if line[:move]
                ret[:move] = line[:move]
              else
                ret[:special] = special2csa(line[:move])
              end
              ret[:time] = line[:time] if line[:time]
              ret
            }.call(s1, s2)
            s0 = s1
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
        if s2 != :failed
          s3 = parse_nl
          if s3 != :failed
            s0 = s1 = [s1, s2, s3]
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

    def parse_line
      s0 = @current_pos
      s1 = []
      s2 = match_str(" ")
      while s2 != :failed
        s1 << s2
        s2 = match_str(" ")
      end
      if s1 != :failed
        s2 = parse_te
        if s2 != :failed
          s3 = []
          s4 = match_str(" ")
          while s4 != :failed
            s3 << s4
            s4 = match_str(" ")
          end
          if s3 != :failed
            s4 = @current_pos
            s5 = parse_fugou
            if s5 != :failed
              s6 = parse_from
              if s6 != :failed
                @reported_pos = s4
                s5 = -> (fugou, from) {
                  ret = { piece: fugou[:piece] }
                  if fugou[:to]
                    ret[:to] = fugou[:to]
                  else
                    ret[:same] = true
                  end
                  ret[:promote] = true if fugou[:promote]
                  ret[:from] = from if from
                  ret
                }.call(s5, s6)
                s4 = s5
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
              s5 = []
              s6 = match_regexp(/^[^\r\n ]/)
              while s6 != :failed
                s5 << s6
                s6 = match_regexp(/^[^\r\n ]/)
              end
              @reported_pos = s4
              s4 = s5 = s5.join
            end
            if s4 != :failed
              s5 = []
              s6 = match_str(" ")
              while s6 != :failed
                s5 << s6
                s6 = match_str(" ")
              end
              if s5 != :failed
                s6 = parse_time
                s6 = nil if s6 == :failed
                if s6 != :failed
                  s7 = match_str("+")
                  s7 = nil if s7 == :failed
                  if s7 != :failed
                    s8 = parse_nl
                    if s8 != :failed
                      @reported_pos = s0
                      s0 = s1 = { move: s4, time: s6 }
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

    def parse_te
      s0 = []
      s1 = match_regexp(/^[0-9]/)
      if s1 != :failed
        while s1 != :failed
          s0 << s1
          s1 = match_regexp(/^[0-9]/)
        end
      else
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
          s3 = match_str("成")
          s3 = nil if s3 == :failed
          if s3 != :failed
            @reported_pos = s0
            s0 = s1 = { to: s1, piece: s2, promote: !!s3 }
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

    def parse_place
      s0 = @current_pos
      s1 = parse_num
      if s1 != :failed
        s2 = parse_numkan
        if s2 != :failed
          @reported_pos = s0
          s0 = s1 = { x: s1, y: s2 }
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
        s1 = match_str("同　")
        if s1 != :failed
          @reported_pos = s0
          s1 = nil
        end
        s0 = s1
      end
      s0
    end

    def parse_num
      s0 = @current_pos
      s1 = match_regexp(/^[１２３４５６７８９]/)
      if s1 != :failed
        @reported_pos = s0
        s1 = zen2n(s1)
      end
      s1
    end

    def parse_numkan
      s0 = @current_pos
      s1 = match_regexp(/^[一二三四五六七八九]/)
      if s1 != :failed
        @reported_pos = s0
        s1 = kan2n(s1)
      end
      s1
    end

    def parse_piece
      s0 = @current_pos
      s1 = match_str("成")
      s1 = "" if s1 == :failed
      if s1 != :failed
        s2 = match_regexp(/^[歩香桂銀金角飛王玉と杏圭全馬竜龍]/)
        if s2 != :failed
          @reported_pos = s0
          s0 = s1 = kind2csa(s1+s2)
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

    def parse_from
      s0 = @current_pos
      s1 = match_str("打")
      if s1 != :failed
        @reported_pos = s0
        s1 = nil
      end
      s0 = s1
      if s0 == :failed
        s0 = @current_pos
        s1 = match_str("(")
        if s1 != :failed
          s2 = match_regexp(/^[1-9]/)
          if s2 != :failed
            s3 = match_regexp(/^[1-9]/)
            if s3 != :failed
              s4 = match_str(")")
              if s4 != :failed
                @reported_pos = s0
                s0 = s1 = { x: s2.to_i, y: s3.to_i }
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
      end
      s0
    end

    def parse_time
      s0 = @current_pos
      s1 = match_str("(")
      if s1 != :failed
        s2 = []
        s3 = match_str(" ")
        while s3 != :failed
          s2 << s3
          s3 = match_str(" ")
        end
        if s2 != :failed
          s3 = parse_ms
          if s3 != :failed
            s4 = match_str("/")
            if s4 != :failed
              s5 = parse_hms
              if s5 != :failed
                s6 = match_str(")")
                if s6 != :failed
                  @reported_pos = s0
                  s0 = s1 = { now: s3, total: s5 }
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

    def parse_hms
      s0 = @current_pos
      s1 = []
      s2 = match_regexp(/^[0-9]/)
      if s2 != :failed
        while s2 != :failed
          s1 << s2
          s2 = match_regexp(/^[0-9]/)
        end
      else
        s1 = :failed
      end

      if s1 != :failed
        s2 = match_str(":")
        if s2 != :failed
          s3 = []
          s4 = match_regexp(/^[0-9]/)
          if s4 != :failed
            while s4 != :failed
              s3 << s4
              s4 = match_regexp(/^[0-9]/)
            end
          else
            s3 = :failed
          end
          if s3 != :failed
            s4 = match_str(":")
            if s4 != :failed
              s5 = []
              s6 = match_regexp(/^[0-9]/)
              if s6 != :failed
                while s6 != :failed
                  s5 << s6
                  s6 = match_regexp(/^[0-9]/)
                end
              else
                s5 = :failed
              end
              if s5 != :failed
                @reported_pos = s0
                s0 = s1 = { h: s1.join.to_i, m: s3.join.to_i, s: s5.join.to_i }
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

    def parse_ms
      s0 = @current_pos
      s1 = []
      s2 = match_regexp(/^[0-9]/)
      if s2 != :failed
        while s2 != :failed
          s1 << s2
          s2 = match_regexp(/^[0-9]/)
        end
      else
        s1 = :failed
      end
      if s1 != :failed
        s2 = match_str(":")
        if s2 != :failed
          s3 = []
          s4 = match_regexp(/^[0-9]/)
          if s4 != :failed
            while s4 != :failed
              s3 << s4
              s4 = match_regexp(/^[0-9]/)
            end
          else
            s3 = :failed
          end
          if s3 != :failed
            @reported_pos = s0
            s0 = s1 = { m: s1.join.to_i, s: s3.join.to_i }
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

    def parse_comment
      s0 = @current_pos
      s1 = match_str("*")
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
            s1 = s2.join
            s0 = s1
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
        s1 = match_str("&")
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
              s0 = s1 = "&" + s2.join
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

    def parse_result
      s0 = @current_pos
      s1 = match_str("まで")

      if s1 != :failed
        s2 = []
        s3 = match_regexp(/^[0-9]/)
        if s3 != :failed
          while s3 != :failed
            s2 << s3
            s3 = match_regexp(/^[0-9]/)
          end
        else
          s2 = :failed
        end
        if s2 != :failed
          s3 = match_str("手")
          if s3 != :failed
            s4 = @current_pos
            s5 = match_str("で")
            if s5 != :failed
              s6 = @parse_turn
              if s6 != :failed
                s7 = match_str("手の")
                if s7 != :failed
                  s8 = @current_pos
                  s9 = match_str("勝ち")
                  if s9 != :failed
                    @reported_pos = s8
                    s9 = "TORYO"
                  end
                  s8 = s9
                  if s8 == :failed
                    s8 = @current_pos
                    s9 = match_str("反則")
                    if s9 != :failed
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
                        @reported_pos = s8
                        s8 = s9 = s10
                      else
                        @current_pos = s8
                        s8 = :failed
                      end
                    else
                      @current_pos = s8
                      s8 = :failed
                    end
                  end
                  if s8 != :failed
                    @reported_pos = s4
                    s4 = s5 = s8
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
            else
              @current_pos = s4
              s4 = :failed
            end
            if s4 == :failed
              s4 = @current_pos
              s5 = match_str("で時間切れにより")
              if s5 != :failed
                s6 = parse_turn
                if s6 != :failed
                  s7 = match_str("手の勝ち")
                  if s7 != :failed
                    @reported_pos = s4
                    s4 = s5 = "TIME_UP"
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
                      s5 = match_str("で")
                      s5 = nil if s5 == :failed
                      if s5 != :failed
                        s6 = match_str("詰")
                        if s6 != :failed
                          s7 = match_str("み")
                          s7 = nil if s7 == :failed
                          if s7 != :failed
                            @reported_pos = s4
                            s4 = s5 = "TSUMI"
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
              s5 = parse_nl
              if s5 != :failed
                @reported_pos = s0
                s0 = s1 = s4
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

    def parse_fork
      s0 = @current_pos
      s1 = match_str("変化：")
      if s1 != :failed
        s2 = []
        s3 = match_str(" ")
        while s3 != :failed
          s2 << s3
          s3 = match_str(" ")
        end
        if s2 != :failed
          s3 = parse_te
          if s3 != :failed
            s4 = match_str("手")
            if s4 != :failed
              s5 = parse_nl
              if s5 != :failed
                s6 = parse_moves
                if s6 != :failed
                  @reported_pos = s0
                  s0 = s1 = { te: s3.join.to_i, moves: s6[1..-1] }
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

    def parse_nl
      s0 = @current_pos
      s1 = []
      s2 = parse_newline
      if s2 != :failed
        while (s2 != :failed)
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
        if s2 != :failed
          s3 = parse_newline
          if s3 != :failed
            s0 = s1 = [s1, s2, s3]
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

    def parse_whitespace
      match_regexp(/^[ \t]/)
    end

    def parse_newline
      s0 = @current_pos
      s1 = []
      s2 = parse_whitespace
      while s2 != :failed
        s1 << s2
        s2 = parse_whitespace
      end
      if s1 != :failed
        s2 = match_str("\n")
        if s2 == :failed
          s2 = @current_pos
          s3 = match_str("\r")
          if s3 != :failed
            s4 = match_str("\n")
            s4 = nil if s4 == :failed
            if s4 != :failed
              s2 = s3 = [s3, s4]
            else
              @current_pos = s2
              s2 = :failed
            end
          else
            @current_pos = s2
            s2 = :failed
          end
        end
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
      s0
    end

    def parse_nonl
      match_regexp(/^[^\r\n]/)
    end

    protected

    def match_regexp(reg)
      ret = nil
      if matched = reg.match(@input[@current_pos])
        ret = matched.to_s
        @current_pos += ret.size
      else
        ret = :failed
        fail({ type: "class", value: reg.inspect, description: reg.inspect }) if @silent_fails == 0
      end
      ret
    end

    def match_str(str)
      ret = nil
      if @input[@current_pos, str.size] == str
        ret = str
        @current_pos += str.size
      else
        ret = :failed
        fail({ type: "literal", value: str, description: "\"#{str}\"" }) if @slient_fails == 0
      end
      ret
    end

    def fail(expected)
      return if @current_pos < @max_fail_pos

      if @current_pos > @max_fail_pos
        @max_fail_pos = @current_pos
        @max_fail_expected = []
      end

      @max_fail_expected << expected
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
        "〇一二三四五六七八九十".index(s[1])+10
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

    def special2csa(str)
      {
        "中断" => "CHUDAN",
        "投了" => "TORYO",
        "持将棋" => "JISHOGI",
        "千日手" => "SENNICHITE",
        "詰み" => "TSUMI",
        "不詰" => "FUZUMI",
        "切れ負け" => "TIME_UP",
        "反則勝ち" => "ILLEGAL_ACTION", # 直前の手が反則(先頭に+か-で反則した側の情報を含める必要が有る)
        "反則負け" => "ILLEGAL_MOVE" # ここで手番側が反則，反則の内容はコメントで表現
      }[str]
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
        "その他" => "OTHER",
      }[preset.gsub(/\s/, "")]
    end

    def make_hand(str)
      # Kifu for iPhoneは半角スペース区切り
      kinds = str.split(/[ 　]/)
      ret = { "FU" => 0, "KY" => 0, "KE" => 0, "GI" => 0, "KI" => 0, "KA" => 0, "HI" => 0 }
      return ret if str.empty?

      kinds.each do |kind|
        next if kind.empty?
        ret[kind2csa(kind[0])] = kind.length == 1 ? 1 : kan2n2(kind[1..-1])
      end

      ret
    end
  end
end
