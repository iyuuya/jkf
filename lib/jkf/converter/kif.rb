module Jkf::Converter
  class Kif
    def convert(jkf)
      hash = if jkf.is_a?(Hash)
               jkf
             else
               JSON.parse(jkf)
             end
      @forks = []

      result = ''
      result += convert_header(hash['header']) if hash['header']
      result += convert_initial(hash['initial']) if hash['initial']
      result += "手数----指手---------消費時間--\n"
      result += convert_moves(hash['moves'])
      if @forks.size > 0
        result += "\n"
        result += @forks.join("\n")
      end

      result
    end

    protected

    def convert_header(header)
      header.map { |(key, value)| "#{key}：#{value}\n" }.join
    end

    def convert_initial(initial)
      result = ''
      result += "手合割：#{preset2str(initial["preset"])}\n" if initial["preset"] != "OTHER"

      data = initial["data"]

      if data
        if data['color'] == 0
          result += "先手番\n"
        elsif data['color'] == 1
          result += "後手番\n"
        end

        if data['hands']
          if data['hands'][0]
            result += '先手の持駒：'
            result += convert_motigoma(data['hands'][0])
          end
          if data['hands'][1]
            result += '後手の持駒：'
            result += convert_motigoma(data['hands'][1])
          end
        end

        if data['board']
          result += "  ９ ８ ７ ６ ５ ４ ３ ２ １\n"
          result += "+---------------------------+\n"
          9.times { |y|
            line = "|"
            9.times { |x|
              line += convert_board_piece(data['board'][8-x][y])
            }
            line += "|#{n2kan(y+1)}\n"
            result += line
          }
          result += "+---------------------------+\n"
        end
      end

      result
    end

    def convert_moves(moves, idx=0)
      result = ''
      moves.each_with_index { |move, i|
        if move['special']
          result_move = "%4d "%(i+idx)
          result_move += ljust(special2kan(move['special']), 13)
          result_move += convert_time(move['time']) if move['time']
          result_move += "+" if move['forks']
          result_move += "\n"
          result += result_move
          # first_board+speical分を引く(-2)
          result += convert_special(move['special'], i-2+idx) if move['special']
        else
          if move['move']
            result_move = "%4d "%(i+idx)
            result_move += convert_move(move['move'])
            result_move += convert_time(move['time']) if move['time']
            result_move += "+" if move['forks']
            result_move += "\n"
            result += result_move
          end

          if move['comments']
            result += convert_comments(move['comments'])
          end

          @forks.unshift convert_forks(move['forks'], i+idx) if move['forks']
        end
      }
      result
    end

    def convert_move(move)
      result = if move['to']
                 n2zen(move['to']['x']) + n2kan(move['to']['y'])
               elsif move['same']
                 '同　'
               else
                 raise "error??"
               end
      result += csa2kind(move['piece'])
      result += '成' if move['promote']
      result += if move['from']
                  "(#{move['from']['x']}#{move['from']['y']})"
                else
                  '打'
                end
      result = ljust(result,13)
      result
    end

    def convert_time(time)
      "(%2d:%02d/%02d:%02d:%02d)"%[
        time['now']['m'],
        time['now']['s'],
        time['total']['h'],
        time['total']['m'],
        time['total']['s'],
      ]
    end

    def convert_special(special, index)
      result = "まで#{index+1}手"

      if special == 'TORYO' || special =~ /ILLEGAL/
        turn = index % 2 == 0 ? '後' : '先'
        result += "で#{turn}手の"
        result += case special
                  when "TORYO"          then "勝ち"
                  when "ILLEGAL_ACTION" then "反則勝ち"
                  when "ILLEGAL_MOVE"   then "反則負け"
                  end
      else
        turn = index % 2 == 0 ? '先' : '後'
        result += case special
                  when "TIME_UP"    then "で時間切れにより#{turn}手の勝ち"
                  when "CHUDAN"     then "で中断"
                  when "JISHOGI"    then "で持将棋"
                  when "SENNICHITE" then "で千日手"
                  when "TSUMI"      then "で詰み"
                  when "FUZUMI"     then "で不詰"
                  end
      end

      result += "\n"
      result
    end

    def convert_comments(comments)
      comments.map { |comment| "*#{comment}\n" }.join
    end

    def convert_forks(forks, index)
      result = "\n"
      result = "変化：%4d手\n"%[index]
      forks.each do |moves|
        result += convert_moves(moves, index)
      end
      result
    end

    def convert_board_piece(piece)
      result = ''

      if piece == {}
        result = ' ・'
      else
        result += piece['color'] == 0 ?  ' ' : 'v'
        result += csa2kind(piece['kind'])
      end

      result
    end

    def convert_motigoma(pieces)
      pieces.map do |piece, num|
        if num > 0
          str = csa2kind(piece)
          if num > 1
            str += n2kan(num/10) if num / 10 > 0
            num %= 10
            str += n2kan(num)
          end
          str
        else
          nil
        end
      end.compact.join('　') + "　\n"
    end

    protected

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
        "KY"     => "香落ち",
        "KY_R"   => "右香落ち",
        "KA"     => "角落ち",
        "HI"     => "飛車落ち",
        "HIKY"   => "飛香落ち",
        "2"      => "二枚落ち",
        "3"      => "三枚落ち",
        "4"      => "四枚落ち",
        "5"      => "五枚落ち",
        "5_L"    => "左五枚落ち",
        "6"      => "六枚落ち",
        "8"      => "八枚落ち",
        "10"     => "十枚落ち",
        "OTHER"  => "その他"
      }[preset]
    end

    def special2kan(special)
      case special
      when "CHUDAN"         then "中断"
      when "TORYO"          then "投了"
      when "JISHOGI"        then "持将棋"
      when "SENNICHITE"     then "千日手"
      when "TSUMI"          then "詰み"
      when "FUZUMI"         then "不詰"
      when "TIME_UP"        then "切れ負け"
      when "ILLEGAL_ACTION" then "反則勝ち"
      when "ILLEGAL_MOVE"   then "反則負け"
      end
    end

    def ljust(str, n)
      len = 0
      str.each_codepoint { |codepoint| len += codepoint > 255 ? 2 : 1 }
      str + ' '*(n-len)
    end
  end
end
