module Jkf
  module Parser
    # KIF Parser
    class Kif < Base
      include Kifuable

      protected

      # kifu : skipline* header* initialboard? header* split? moves fork* nl?
      def parse_root
        @scanner << "\n" unless @scanner.string.end_with?("\n")

        s0 = @scanner.pos
        s1 = []
        s2 = parse_skipline
        while s2 != :failed
          s1 << s2
          s2 = parse_skipline
        end

        s2 = []
        s3 = parse_header
        while s3 != :failed
          s2 << s3
          s3 = parse_header
        end
        s3 = parse_initialboard
        s3 = nil if s3 == :failed
        s4 = []
        s5 = parse_header
        while s5 != :failed
          s4 << s5
          s5 = parse_header
        end
        parse_split
        s6 = parse_moves
        if s6 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s7 = []
          s8 = parse_fork
          while s8 != :failed
            s7 << s8
            s8 = parse_fork
          end
          parse_nl
          @reported_pos = s0
          s0 = transform_root(s2, s3, s4, s6, s7)
        end

        s0
      end

      # header : [^：\r\n]+ "：" nonls nl
      #        | turn "手番" nl
      #        | "盤面回転" nl
      def parse_header
        s0 = @scanner.pos
        s2 = match_regexp(/[^：\r\n]/)
        if s2 == :failed
          s1 = :failed
        else
          s1 = []
          while s2 != :failed
            s1 << s2
            s2 = match_regexp(/[^：\r\n]/)
          end
        end
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        elsif match_str('：') != :failed
          s3 = parse_nonls
          if parse_nl == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s1 = { 'k' => s1.join, 'v' => s3.join }
            s0 = s1
          end
        else
          @scanner.pos = s0
          s0 = :failed
        end
        if s0 == :failed
          s0 = @scanner.pos
          s1 = parse_turn
          if s1 == :failed
            @scanner.pos = s0
            s0 = :failed
          elsif match_str('手番') != :failed
            if parse_nl == :failed
              @scanner.pos = s0
              s0 = :failed
            else
              @reported_pos = s0
              s0 = { 'k' => '手番', 'v' => s1 }
            end
          else
            @scanner.pos = s0
            s0 = :failed
          end
          if s0 == :failed
            s0 = @scanner.pos
            if match_str('盤面回転') == :failed
              @scanner.pos = s0
              s0 = :failed
            elsif parse_nl != :failed
              @reported_pos = s0
              s0 = nil
            else
              @scanner.pos = s0
              s0 = :failed
            end
          end
        end

        s0
      end

      # turn : [先後上下]
      def parse_turn
        match_regexp(/[先後上下]/)
      end

      # split : "手数----指手--" "-------消費時間--"? nl
      def parse_split
        s0 = @scanner.pos
        s1 = match_str('手数----指手--')
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s2 = match_str('-------消費時間--')
          s2 = nil if s2 == :failed
          s3 = parse_nl
          if s3 == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            s0 = [s1, s2, s3]
          end
        end
        s0
      end

      # moves : firstboard split? move* result?
      def parse_moves
        s0 = @scanner.pos
        s1 = parse_firstboard
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          parse_split
          s2 = []
          s3 = parse_move
          while s3 != :failed
            s2 << s3
            s3 = parse_move
          end
          parse_result
          @reported_pos = s0
          s0 = s2.unshift(s1)
        end
        s0
      end

      # firstboard : comment* pointer?
      def parse_firstboard
        s0 = @scanner.pos
        s1 = []
        s2 = parse_comment
        while s2 != :failed
          s1 << s2
          s2 = parse_comment
        end
        parse_pointer
        @reported_pos = s0
        s1.empty? ? {} : { 'comments' => s1 }
      end

      # move : line comment* pointer?
      def parse_move
        s0 = @scanner.pos
        s1 = parse_line
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s2 = []
          s3 = parse_comment
          while s3 != :failed
            s2 << s3
            s3 = parse_comment
          end
          parse_pointer
          @reported_pos = s0
          s0 = transform_move(s1, s2)
        end
        s0
      end

      # line : " "* te " "* (fugou from | [^\r\n ]*) " "* time? "+"? nl
      def parse_line
        s0 = @scanner.pos
        match_spaces
        s2 = parse_te
        if s2 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          match_spaces
          s4 = @scanner.pos
          s5 = parse_fugou
          if s5 == :failed
            @scanner.pos = s4
            s4 = :failed
          else
            s6 = parse_from
            if s6 == :failed
              @scanner.pos = s4
              s4 = :failed
            else
              @reported_pos = s4
              s4 = transform_teban_fugou_from(s2, s5, s6)
            end
          end
          if s4 == :failed
            s4 = @scanner.pos
            s5 = []
            s6 = match_regexp(/[^\r\n ]/)
            while s6 != :failed
              s5 << s6
              s6 = match_regexp(/[^\r\n ]/)
            end
            @reported_pos = s4
            s4 = s5.join
          end
          if s4 == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            match_spaces
            s6 = parse_time
            s6 = nil if s6 == :failed
            match_str('+')
            if parse_nl == :failed
              @scanner.pos = s0
              s0 = :failed
            else
              @reported_pos = s0
              s0 = { 'move' => s4, 'time' => s6 }
            end
          end
        end
        s0
      end

      # te : [0-9]+
      def parse_te
        match_digits!
      end

      # fugou : place piece "成"?
      def parse_fugou
        s0 = @scanner.pos
        s1 = parse_place
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s2 = parse_piece
          if s2 == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            s3 = match_str('成')
            s3 = nil if s3 == :failed
            @reported_pos = s0
            s0 = { 'to' => s1, 'piece' => s2, 'promote' => !!s3 }
          end
        end
        s0
      end

      # place : num numkan | "同　"
      def parse_place
        s0 = @scanner.pos
        s1 = parse_num
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s2 = parse_numkan
          if s2 == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = { 'x' => s1, 'y' => s2 }
          end
        end
        if s0 == :failed
          s0 = @scanner.pos
          s1 = match_str('同　')
          if s1 != :failed
            @reported_pos = s0
            s1 = nil
          end
          s0 = s1
        end
        s0
      end

      # from : "打" | "(" [1-9] [1-9] ")"
      def parse_from
        s0 = @scanner.pos
        s1 = match_str('打')
        if s1 != :failed
          @reported_pos = s0
          s1 = nil
        end
        s0 = s1
        if s0 == :failed
          s0 = @scanner.pos
          if match_str('(') == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            s2 = match_regexp(/[1-9]/)
            if s2 == :failed
              @scanner.pos = s0
              s0 = :failed
            else
              s3 = match_regexp(/[1-9]/)
              if s3 == :failed
                @scanner.pos = s0
                s0 = :failed
              elsif match_str(')') != :failed
                @reported_pos = s0
                s0 = { 'x' => s2.to_i, 'y' => s3.to_i }
              else
                @scanner.pos = s0
                s0 = :failed
              end
            end
          end
        end
        s0
      end

      # time :  "(" " "* ms " "* "/" " "* (hms | ms) " "* ")"
      def parse_time
        s0 = @scanner.pos
        if match_str('(') == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          match_spaces
          s3 = parse_ms
          if s3 == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            match_spaces
            if match_str('/') == :failed
              @scanner.pos = s0
              s0 = :failed
            else
              match_spaces
              s5 = parse_hms
              s5 = parse_ms(with_hour: true) if s5 == :failed
              if s5 == :failed
                @scanner.pos = s0
                s0 = :failed
              else
                match_spaces
                if match_str(')') == :failed
                  @scanner.pos = s0
                  s0 = :failed
                else
                  @reported_pos = s0
                  s0 = { 'now' => s3, 'total' => s5 }
                end
              end
            end
          end
        end
        s0
      end

      # hms : [0-9]+ ":" [0-9]+ ":" [0-9]+
      def parse_hms
        s0 = @scanner.pos
        s1 = match_digits!

        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        elsif match_str(':') != :failed
          s3 = match_digits!
          if s3 == :failed
            @scanner.pos = s0
            s0 = :failed
          elsif match_str(':') != :failed
            s5 = match_digits!
            if s5 == :failed
              @scanner.pos = s0
              s0 = :failed
            else
              @reported_pos = s0
              s0 = { 'h' => s1.join.to_i, 'm' => s3.join.to_i, 's' => s5.join.to_i }
            end
          else
            @scanner.pos = s0
            s0 = :failed
          end
        else
          @scanner.pos = s0
          s0 = :failed
        end
        s0
      end

      # ms : [0-9]+ ":" [0-9]+
      def parse_ms(with_hour: false)
        s0 = @scanner.pos
        s1 = match_digits!
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        elsif match_str(':') != :failed
          s3 = match_digits!
          if s3 == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            m = s1.join.to_i
            s = s3.join.to_i
            if with_hour
              h = m / 60
              m = m % 60
              s0 = { 'h' => h, 'm' => m, 's' => s }
            else
              s0 = { 'm' => m, 's' => s }
            end
          end
        else
          @scanner.pos = s0
          s0 = :failed
        end
        s0
      end

      # comment : "*" nonls nl | "&" nonls nl
      def parse_comment
        s0 = @scanner.pos
        if match_str('*') == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s2 = parse_nonls
          if parse_nl == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = s2.join
          end
        end
        if s0 == :failed
          s0 = @scanner.pos
          s1 = match_str('&')
          if s1 == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            s2 = parse_nonls
            if parse_nl == :failed
              @scanner.pos = s0
              s0 = :failed
            else
              @reported_pos = s0
              s0 = '&' + s2.join
            end
          end
        end
        s0
      end

      # fork :  "変化：" " "* [0-9]+ "手" nl moves
      def parse_fork
        s0 = @scanner.pos
        if match_str('変化：') == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          match_spaces
          s3 = parse_te
          if s3 == :failed
            @scanner.pos = s0
            s0 = :failed
          elsif match_str('手') != :failed
            if parse_nl == :failed
              @scanner.pos = s0
              s0 = :failed
            else
              s6 = parse_moves
              if s6 == :failed
                @scanner.pos = s0
                s0 = :failed
              else
                @reported_pos = s0
                s0 = { 'te' => s3.join.to_i, 'moves' => s6[1..-1] }
              end
            end
          else
            @scanner.pos = s0
            s0 = :failed
          end
        end
        s0
      end

      # transfrom to jkf
      def transform_root(headers, ini, headers2, moves, forks)
        ret = { 'header' => {}, 'moves' => moves }
        headers.compact.each { |h| ret['header'][h['k']] = h['v'] }
        headers2.compact.each { |h| ret['header'][h['k']] = h['v'] }
        if ini
          ret['initial'] = ini
        elsif ret['header']['手合割']
          preset = preset2str(ret['header']['手合割'])
          ret['initial'] = { 'preset' => preset } if preset && preset != 'OTHER'
        end
        transform_root_header_data(ret) if ret['initial'] && ret['initial']['data']
        transform_root_forks(forks, moves)
        if ret['initial'] && ret['initial']['data'] && ret['initial']['data']['color'] == 1
          reverse_color(ret['moves'])
        end
        ret
      end

      # transform move to jkf
      def transform_move(line, c)
        ret = {}
        ret['comments'] = c unless c.empty?
        if line['move'].is_a? Hash
          ret['move'] = line['move']
        else
          ret['special'] = special2csa(line['move'])
        end
        ret['time'] = line['time'] if line['time']
        ret
      end

      # transform teban-fugou-from to jkf
      def transform_teban_fugou_from(teban, fugou, from)
        ret = { 'color' => teban2color(teban.join), 'piece' => fugou['piece'] }
        if fugou['to']
          ret['to'] = fugou['to']
        else
          ret['same'] = true
        end
        ret['promote'] = true if fugou['promote']
        ret['from'] = from if from
        ret
      end

      # special string to csa
      def special2csa(str)
        {
          '中断' => 'CHUDAN',
          '投了' => 'TORYO',
          '持将棋' => 'JISHOGI',
          '千日手' => 'SENNICHITE',
          '詰み' => 'TSUMI',
          '不詰' => 'FUZUMI',
          '切れ負け' => 'TIME_UP',
          '反則勝ち' => 'ILLEGAL_ACTION', # 直前の手が反則(先頭に+か-で反則した側の情報を含める必要が有る)
          '反則負け' => 'ILLEGAL_MOVE' # ここで手番側が反則，反則の内容はコメントで表現
        }[str] || (raise ParseError)
      end

      # teban to color
      def teban2color(teban)
        teban = teban.to_i unless teban.is_a? Integer
        (teban + 1) % 2
      end

      # generate motigoma
      def make_hand(str)
        # Kifu for iPhoneは半角スペース区切り
        ret = { 'FU' => 0, 'KY' => 0, 'KE' => 0, 'GI' => 0, 'KI' => 0, 'KA' => 0, 'HI' => 0 }
        return ret if str.empty?

        str.split(/[ 　]/).each do |kind|
          next if kind.empty?
          ret[kind2csa(kind[0])] = kind.length == 1 ? 1 : kan2n2(kind[1..-1])
        end

        ret
      end

      # exchange sente gote
      def reverse_color(moves)
        moves.each do |move|
          if move['move'] && move['move']['color']
            move['move']['color'] = (move['move']['color'] + 1) % 2
          end
          move['forks']&.each { |fork| reverse_color(fork) }
        end
      end
    end
  end
end
