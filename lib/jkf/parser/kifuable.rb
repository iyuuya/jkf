module Jkf
  module Parser
    # Intersection of KIF and KI2
    module Kifuable
      protected

      # initialboard : (" " nonls nl)? ("+" nonls nl)? ikkatsuline+ ("+" nonls nl)?
      def parse_initialboard
        s0 = s1 = @scanner.pos
        if match_space == :failed
          @scanner.pos = s1
        else
          parse_nonls
          s2 = parse_nl
          @scanner.pos = s1 if s2 == :failed
        end
        s2 = @scanner.pos
        if match_str('+') == :failed
          @scanner.pos = s2
        else
          parse_nonls
          @scanner.pos = s2 if parse_nl == :failed
        end
        s4 = parse_ikkatsuline
        if s4 == :failed
          s3 = :failed
        else
          s3 = []
          while s4 != :failed
            s3 << s4
            s4 = parse_ikkatsuline
          end
        end
        if s3 == :failed
          @scanner.pos = s0
          :failed
        else
          s4 = @scanner.pos
          if match_str('+') == :failed
            @scanner.pos = s4
          else
            parse_nonls
            @scanner.pos = s4 if parse_nl == :failed
          end
          @reported_pos = s0
          transform_initialboard(s3)
        end
      end

      # ikkatsuline : "|" masu:masu+ "|" nonls! nl
      def parse_ikkatsuline
        s0 = @scanner.pos
        if match_str('|') == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s3 = parse_masu
          if s3 == :failed
            s2 = :failed
          else
            s2 = []
            while s3 != :failed
              s2 << s3
              s3 = parse_masu
            end
          end
          if s2 == :failed
            @scanner.pos = s0
            s0 = :failed
          elsif match_str('|') != :failed
            s4 = parse_nonls!
            if s4 == :failed
              @scanner.pos = s0
              s0 = :failed
            elsif parse_nl != :failed
              @reported_pos = s0
              s0 = s2
            else
              @scanner.pos = s0
              s0 = :failed
            end
          else
            @scanner.pos = s0
            s0 = :failed
          end
        end

        s0
      end

      # masu : teban piece | " ・"
      def parse_masu
        s0 = @scanner.pos
        s1 = parse_teban
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s2 = parse_piece
          if s2 == :failed
            @scanner.pos = s0
            s0 = :failed
          else
            @reported_pos = s0
            s0 = { 'color' => s1, 'kind' => s2 }
          end
        end
        if s0 == :failed
          s0 = @scanner.pos
          s1 = match_str(' ・')
          if s1 != :failed
            @reported_pos = s0
            s1 = {}
          end
          s0 = s1
        end

        s0
      end

      # teban : (" " | "+" | "^") | ("v" | "V")
      def parse_teban
        s0 = @scanner.pos
        s1 = match_space
        if s1 == :failed
          s1 = match_str('+')
          s1 = match_str('^') if s1 == :failed
        end
        if s1 != :failed
          @reported_pos = s0
          s1 = 0
        end
        s0 = s1
        if s0 == :failed
          s0 = @scanner.pos
          s1 = match_str('v')
          s1 = match_str('V') if s1 == :failed
          if s1 != :failed
            @reported_pos = s0
            s1 = 1
          end
          s0 = s1
        end
        s0
      end

      # pointer : "&" nonls nl
      def parse_pointer
        s0 = @scanner.pos
        s1 = match_str('&')
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s2 = parse_nonls
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

      # num : [１２３４５６７８９]
      def parse_num
        s0 = @scanner.pos
        s1 = match_regexp(/[１２３４５６７８９]/)
        if s1 != :failed
          @reported_pos = s0
          s1 = zen2n(s1)
        end
        s1
      end

      # numkan : [一二三四五六七八九]
      def parse_numkan
        s0 = @scanner.pos
        s1 = match_regexp(/[一二三四五六七八九]/)
        if s1 != :failed
          @reported_pos = s0
          s1 = kan2n(s1)
        end
        s1
      end

      # piece : "成"? [歩香桂銀金角飛王玉と杏圭全馬竜龍]
      def parse_piece
        s0 = @scanner.pos
        s1 = match_str('成')
        s1 = '' if s1 == :failed
        s2 = match_regexp(/[歩香桂銀金角飛王玉と杏圭全馬竜龍]/)
        if s2 == :failed
          @scanner.pos = s0
          :failed
        else
          @reported_pos = s0
          kind2csa(s1 + s2)
        end
      end

      # result : "まで" [0-9]+ "手" (
      #            "で" (turn "手の" (result_toryo | result_illegal)) |
      #            result_timeup | result_chudan | result_jishogi |
      #            result_sennichite | result_tsumi | result_fuzumi
      #          ) nl
      def parse_result
        s0 = @scanner.pos
        if match_str('まで') == :failed
          @scanner.pos = s0
          :failed
        else
          s2 = match_digits!
          if s2 == :failed
            @scanner.pos = s0
            :failed
          elsif match_str('手') != :failed
            s4 = @scanner.pos
            if match_str('で') == :failed
              @scanner.pos = s4
              s4 = :failed
            elsif parse_turn != :failed
              if match_str('手の') == :failed
                @scanner.pos = s4
                s4 = :failed
              else
                s8 = parse_result_toryo
                s8 = parse_result_illegal if s8 == :failed
                s4 = if s8 == :failed
                       @scanner.pos = s4
                       :failed
                     else
                       @reported_pos = s4
                       s8
                     end
              end
            else
              @scanner.pos = s4
              s4 = :failed
            end
            if s4 == :failed
              s4 = parse_result_timeup
              if s4 == :failed
                s4 = parse_result_chudan
                if s4 == :failed
                  s4 = parse_result_jishogi
                  if s4 == :failed
                    s4 = parse_result_sennichite
                    if s4 == :failed
                      s4 = parse_result_tsumi
                      s4 = parse_result_fuzumi if s4 == :failed
                    end
                  end
                end
              end
            end
            if s4 == :failed
              @scanner.pos = s0
              :failed
            elsif parse_nl != :failed || eos?
              @reported_pos = s0
              s4
            else
              @scanner.pos = s0
              :failed
            end
          else
            @scanner.pos = s0
            :failed
          end
        end
      end

      # result_toryo : "勝ち"
      def parse_result_toryo
        s0 = @scanner.pos
        s1 = match_str('勝ち')
        if s1 == :failed
          @scanner.pos = s0
          :failed
        else
          @reported_pos = s0
          'TORYO'
        end
      end

      # result_illegal : "反則" ("勝ち" | "負け")
      def parse_result_illegal
        s0 = @scanner.pos
        if match_str('反則') == :failed
          @scanner.pos = s0
          :failed
        else
          s10 = @scanner.pos
          s11 = match_str('勝ち')
          if s11 != :failed
            @reported_pos = s10
            s11 = 'ILLEGAL_ACTION'
          end
          s10 = s11
          if s10 == :failed
            s10 = @scanner.pos
            s11 = match_str('負け')
            if s11 != :failed
              @reported_pos = s10
              s11 = 'ILLEGAL_MOVE'
            end
            s10 = s11
          end
          if s10 == :failed
            @scanner.pos = s0
            :failed
          else
            @reported_pos = s0
            s10
          end
        end
      end

      # result_timeup : "で時間切れにより" turn "手の勝ち"
      def parse_result_timeup
        s0 = @scanner.pos
        if match_str('で時間切れにより') != :failed && parse_turn != :failed && match_str('手の勝ち') != :failed
          @reported_pos = s0
          'TIME_UP'
        else
          @scanner.pos = s0
          :failed
        end
      end

      # result_chudan : "で中断"
      def parse_result_chudan
        s0 = @scanner.pos
        s1 = match_str('で中断')
        if s1 == :failed
          @scanner.pos = s0
          :failed
        else
          @reported_pos = s0
          'CHUDAN'
        end
      end

      # result_jishogi : "で持将棋"
      def parse_result_jishogi
        s0 = @scanner.pos
        s1 = match_str('で持将棋')
        if s1 == :failed
          @scanner.pos = s0
          :failed
        else
          @reported_pos = s0
          'JISHOGI'
        end
      end

      # result_sennichite : "で千日手"
      def parse_result_sennichite
        s0 = @scanner.pos
        s1 = match_str('で千日手')
        if s1 == :failed
          @scanner.pos = s0
          :failed
        else
          @reported_pos = s0
          'SENNICHITE'
        end
      end

      # result_tsumi : "で"? "詰" "み"?
      def parse_result_tsumi
        s0 = @scanner.pos
        match_str('で')
        if match_str('詰') == :failed
          @scanner.pos = s0
          :failed
        else
          match_str('み')
          @reported_pos = s0
          'TSUMI'
        end
      end

      # result_fuzumi : "で不詰"
      def parse_result_fuzumi
        s0 = @scanner.pos
        s1 = match_str('で不詰')
        if s1 == :failed
          @scanner.pos = s0
          :failed
        else
          @reported_pos = s0
          'FUZUMI'
        end
      end

      # skipline : "#" nonls newline
      def parse_skipline
        s0 = @scanner.pos
        s1 = match_str('#')
        if s1 == :failed
          @scanner.pos = s0
          s0 = :failed
        else
          s2 = parse_nonls
          s3 = parse_newline
          s0 = if s3 == :failed
                 @scanner.pos = s0
                 :failed
               else
                 [s1, s2, s3]
               end
        end
        s0
      end

      # whitespace : " " | "\t"
      def parse_whitespace
        match_regexp(/[ \t]/)
      end

      # newline : whitespace* ("\n" | "\r" "\n"?)
      def parse_newline
        s0 = @scanner.pos
        s1 = []
        s2 = parse_whitespace
        while s2 != :failed
          s1 << s2
          s2 = parse_whitespace
        end
        s2 = match_str("\n")
        if s2 == :failed
          s2 = @scanner.pos
          s3 = match_str("\r")
          s2 = if s3 == :failed
                 @scanner.pos = s2
                 :failed
               else
                 s4 = match_str("\n")
                 s4 = nil if s4 == :failed
                 [s3, s4]
               end
        end
        if s2 == :failed
          @scanner.pos = s0
          :failed
        else
          [s1, s2]
        end
      end

      # nl : newline+ skipline*
      def parse_nl
        s0 = @scanner.pos
        s2 = parse_newline
        if s2 == :failed
          s1 = :failed
        else
          s1 = []
          while s2 != :failed
            s1 << s2
            s2 = parse_newline
          end
        end
        if s1 == :failed
          @scanner.pos = s0
          :failed
        else
          s2 = []
          s3 = parse_skipline
          while s3 != :failed
            s2 << s3
            s3 = parse_skipline
          end
          [s1, s2]
        end
      end

      # nonl : 
      def parse_nonl
        match_regexp(/[^\r\n]/)
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

      # nonls! : nonl+
      def parse_nonls!
        matched = parse_nonls
        if matched.empty?
          :failed
        else
          matched
        end
      end

      # transform header-data to jkf
      def transform_root_header_data(ret)
        if ret['header']['手番']
          ret['initial']['data']['color'] = '下先'.include?(ret['header']['手番']) ? 0 : 1
          ret['header'].delete('手番')
        else
          ret['initial']['data']['color'] = 0
        end
        ret['initial']['data']['hands'] = [
          make_hand(ret['header']['先手の持駒'] || ret['header']['下手の持駒']),
          make_hand(ret['header']['後手の持駒'] || ret['header']['上手の持駒'])
        ]
        %w(先手の持駒 下手の持駒 後手の持駒 上手の持駒).each do |key|
          ret['header'].delete(key)
        end
      end

      # transfrom forks to jkf
      def transform_root_forks(forks, moves)
        fork_stack = [{ 'te' => 0, 'moves' => moves }]
        forks.each do |f|
          now_fork = f
          fork = fork_stack.pop
          fork = fork_stack.pop while fork['te'] > now_fork['te']
          move = fork['moves'][now_fork['te'] - fork['te']]
          move['forks'] ||= []
          move['forks'] << now_fork['moves']
          fork_stack << fork
          fork_stack << now_fork
        end
      end

      # transform initialboard to jkf
      def transform_initialboard(lines)
        board = []
        9.times do |i|
          line = []
          9.times do |j|
            line << lines[j][8 - i]
          end
          board << line
        end
        { 'preset' => 'OTHER', 'data' => { 'board' => board } }
      end

      # zenkaku number to number
      def zen2n(s)
        '０１２３４５６７８９'.index(s)
      end

      # kanji number to number (1)
      def kan2n(s)
        '〇一二三四五六七八九'.index(s)
      end

      # kanji number to number (2)
      def kan2n2(s)
        case s.length
        when 1
          '〇一二三四五六七八九十'.index(s)
        when 2
          '〇一二三四五六七八九十'.index(s[1]) + 10
        else
          raise '21以上の数値に対応していません'
        end
      end

      # kanji piece-type to csa
      def kind2csa(kind)
        if kind[0] == '成'
          {
            '香' => 'NY',
            '桂' => 'NK',
            '銀' => 'NG'
          }[kind[1]]
        else
          {
            '歩' => 'FU',
            '香' => 'KY',
            '桂' => 'KE',
            '銀' => 'GI',
            '金' => 'KI',
            '角' => 'KA',
            '飛' => 'HI',
            '玉' => 'OU',
            '王' => 'OU',
            'と' => 'TO',
            '杏' => 'NY',
            '圭' => 'NK',
            '全' => 'NG',
            '馬' => 'UM',
            '竜' => 'RY',
            '龍' => 'RY'
          }[kind]
        end
      end

      # preset string to jkf
      def preset2str(preset)
        {
          '平手' => 'HIRATE',
          '香落ち' => 'KY',
          '右香落ち' => 'KY_R',
          '角落ち' => 'KA',
          '飛車落ち' => 'HI',
          '飛香落ち' => 'HIKY',
          '二枚落ち' => '2',
          '三枚落ち' => '3',
          '四枚落ち' => '4',
          '五枚落ち' => '5',
          '左五枚落ち' => '5_L',
          '六枚落ち' => '6',
          '八枚落ち' => '8',
          '十枚落ち' => '10',
          'その他' => 'OTHER'
        }[preset.gsub(/\s/, '')]
      end
    end
  end
end
