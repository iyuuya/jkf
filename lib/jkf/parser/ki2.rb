module Jkf
  module Parser
    # KI2 Parser
    class Ki2 < Base
      include Kifuable

      protected

      # kifu : header* initialboard? header* moves fork*
      def parse_root
        s0 = @current_pos
        s1 = []
        s2 = parse_header
        while s2 != :failed
          s1 << s2
          s2 = parse_header
        end
        if s1 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s2 = parse_initialboard
          s2 = nil if s2 == :failed
          s3 = []
          s4 = parse_header
          while s4 != :failed
            s3 << s4
            s4 = parse_header
          end
          s4 = parse_moves
          if s4 == :failed
            @current_pos = s0
            s0 = :failed
          else
            s5 = []
            s6 = parse_fork
            while s6 != :failed
              s5 << s6
              s6 = parse_fork
            end
            @reported_pos = s0
            s0 = transform_root(s1, s2, s3, s4, s5)
          end
        end
        s0
      end

      # header : [^：\r\n]+ "：" nonls nl+ | header_teban
      def parse_header
        s0 = @current_pos
        s2 = match_regexp(/^[^*：\r\n]/)
        if s2 == :failed
          s1 = :failed
        else
          s1 = []
          while s2 != :failed
            s1 << s2
            s2 = match_regexp(/^[^：\r\n]/)
          end
        end
        if s1 == :failed
          @current_pos = s0
          s0 = :failed
        elsif match_str('：') != :failed
          s3 = parse_nonls
          s5 = parse_nl
          if s5 == :failed
            s4 = :failed
          else
            s4 = []
            while s5 != :failed
              s4 << s5
              s5 = parse_nl
            end
          end
          if s4 == :failed
            @current_pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = { 'k' => s1.join, 'v' => s3.join }
          end
        else
          @current_pos = s0
          s0 = :failed
        end
        s0 = parse_header_teban if s0 == :failed
        s0
      end

      # header_teban : [先後上下] "手番" nl
      def parse_header_teban
        s0 = @current_pos
        s1 = parse_turn
        if s1 == :failed
          @current_pos = s0
          :failed
        else
          s2 = match_str('手番')
          if s2 == :failed
            @current_pos = s0
            :failed
          else
            s3 = parse_nl
            if s3 == :failed
              @current_pos = s0
              :failed
            else
              @reported_pos = s0
              { 'k' => '手番', 'v' => s1 }
            end
          end
        end
      end

      # moves : firstboard : move* result?
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
          s3 = parse_result
          s3 = nil if s3 == :failed
          @reported_pos = s0
          s0 = -> (hd, tl, res) do
            tl.unshift(hd)
            tl << { 'special' => res } if res && !tl[tl.length - 1]['special']
            tl
          end.call(s1, s2, s3)
        end
        s0
      end

      # firstboard : comment* pointer?
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
        s1.empty? ? {} : { 'comments' => s1 }
      end

      # move : line comment* pointer? (nl | " ")*
      def parse_move
        s0 = @current_pos
        s1 = parse_line
        if s1 == :failed
          @current_pos = s0
          s0 = :failed
        else
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
            ret = { 'move' => line }
            ret['comments'] = c unless c.empty?
            ret
          end.call(s1, s2)
        end

        s0
      end

      # line : [▲△] fugou (nl / " ")*
      def parse_line
        s0 = @current_pos
        s1 = match_regexp(/^[▲△]/)
        if s1 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s1 = if s1 == '▲'
                 { 'color' => 0 }
               else
                 { 'color' => 1 }
               end
          s2 = parse_fugou
          if s2 == :failed
            @current_pos = s0
            s0 = :failed
          else
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
          end
        end
        s0
      end

      # fugou : place piece soutai? dousa? ("成" | "不成")? "打"?
      def parse_fugou
        s0 = @current_pos
        s1 = parse_place
        if s1 == :failed
          @current_pos = s0
          :failed
        else
          s2 = parse_piece
          if s2 == :failed
            @current_pos = s0
            :failed
          else
            s3 = parse_soutai
            s3 = nil if s3 == :failed
            s4 = parse_dousa
            s4 = nil if s4 == :failed
            s5 = match_str('成')
            s5 = match_str('不成') if s5 == :failed
            s5 = nil if s5 == :failed
            s6 = match_str('打')
            s6 = nil if s6 == :failed
            @reported_pos = s0
            transform_fugou(s1, s2, s3, s4, s5, s6)
          end
        end
      end

      # place : num numkan
      def parse_place
        s0 = @current_pos
        s1 = parse_num
        if s1 == :failed
          @current_pos = s0
          s0 = :failed
        else
          s2 = parse_numkan
          if s2 == :failed
            @current_pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = { 'x' => s1, 'y' => s2 }
          end
        end
        if s0 == :failed
          s0 = @current_pos
          if match_regexp('同') == :failed
            @current_pos = s0
            s0 = :failed
          else
            match_str('　')
            @reported_pos = s0
            s0 = { 'same' => true }
          end
        end
        s0
      end

      # soutai : [左直右]
      def parse_soutai
        match_regexp(/^[左直右]/)
      end

      # dousa : [上寄引]
      def parse_dousa
        match_regexp(/^[上寄引]/)
      end

      # "*" nonls nl
      def parse_comment
        s0 = @current_pos
        if match_str('*') == :failed
          @current_pos = s0
          s0 = :failed
        else
          s2 = parse_nonls
          if parse_nl == :failed
            @current_pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = s2.join
          end
        end
        s0
      end

      # fork : "変化：" " "* [0-9]+ "手" nl moves
      def parse_fork
        s0 = @current_pos
        if match_str('変化：') == :failed
          @current_pos = s0
          s0 = :failed
        else
          match_spaces
          s3 = match_digits!
          if s3 == :failed
            @current_pos = s0
            s0 = :failed
          elsif match_str('手') != :failed
            if parse_nl == :failed
              @current_pos = s0
              s0 = :failed
            else
              s6 = parse_moves
              if s6 == :failed
                @current_pos = s0
                s0 = :failed
              else
                @reported_pos = s0
                s0 = { 'te' => s3.join.to_i, 'moves' => s6[1..-1] }
              end
            end
          else
            @current_pos = s0
            s0 = :failed
          end
        end
        s0
      end

      # turn : [先後上下]
      def parse_turn
        match_regexp(/^[先後上下]/)
      end

      # transform to jkf
      def transform_root(headers, ini, headers2, moves, forks)
        ret = { 'header' => {}, 'moves' => moves }
        headers.compact.each { |h| ret['header'][h['k']] = h['v'] }
        headers2.compact.each { |h| ret['header'][h['k']] = h['v'] }
        if ini
          ret['initial'] = ini
        elsif ret['header']['手合割']
          preset = preset2str(ret['header']['手合割'])
          ret['initial'] = { 'preset' => preset } if preset != 'OTHER'
        end
        transform_root_header_data(ret) if ret['initial'] && ret['initial']['data']
        transform_root_forks(forks, moves)
        ret
      end

      # transfrom fugou to jkf
      def transform_fugou(pl, pi, sou, dou, pro, da)
        ret = { 'piece' => pi }
        if pl['same']
          ret['same'] = true
        else
          ret['to'] = pl
        end
        ret['promote'] = (pro == '成') if pro
        if da
          ret['relative'] = 'H'
        else
          rel = soutai2relative(sou) + dousa2relative(dou)
          ret['relative'] = rel unless rel.empty?
        end
        ret
      end

      # relative string to jkf
      def soutai2relative(str)
        {
          '左' => 'L',
          '直' => 'C',
          '右' => 'R'
        }[str] || ''
      end

      # movement string to jkf
      def dousa2relative(str)
        {
          '上' => 'U',
          '寄' => 'M',
          '引' => 'D'
        }[str] || ''
      end

      # generate motigoma
      def make_hand(str)
        ret = { 'FU' => 0, 'KY' => 0, 'KE' => 0, 'GI' => 0, 'KI' => 0, 'KA' => 0, 'HI' => 0 }
        return ret if str.empty?

        str.gsub(/　$/, '').split('　').each do |kind|
          next if kind.empty?
          ret[kind2csa(kind[0])] = kind.length == 1 ? 1 : kan2n2(kind[1..-1])
        end

        ret
      end

      # check eos
      def eos?
        @input[@current_pos].nil?
      end
    end
  end
end
