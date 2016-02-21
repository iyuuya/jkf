module Jkf::Converter
  class Ki2
    def convert(jkf)
      hash = JSON.parse(jkf)

      result = ''
      result += convert_header(hash['header']) if hash['header']
      result += convert_initial(hash['initial']) if hash['initial']
      result += convert_moves(hash['moves']) if hash['moves']

      result
    end

    def convert_header(header)
      header.map { |(key, value)| "#{key}：#{value}\n" }.join
    end

    def convert_initial(initial)
      result = ''
      result += "手合割：#{preset2str(initial["piece"])}\n" if initial["preset"] != "OTHER"

      data = initial["data"]

      if data['color'] == 0
        result += "先手番\n"
      elsif data['color'] == 1
        result += "後手番\n"
      end

      if data['hands']
        if data['hands'][0]
          result += '後手の持駒：'
          result += convert_motigoma(data['hands'][0])
        end
        if data['hands'][1]
          result += '先手の持駒：'
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

      result
    end

    def convert_moves(moves)
      result = "\n"
      i = 0
      before_split = ''
      moves.each_with_index { |move, i|
        if move['special']
          result += "\n"
          # first_board+speical分を引く(-2)
          result += convert_special(move['special'], i-2) if move['special']
        else
          result += before_split
          if move['move']
            result_move = convert_move(move['move'])
            before_split = if i % 6 == 0
                             "\n"
                           else
                             result_move.size == 4 ? " "*4 : " "*2
                           end
            i += 1
            result += result_move
          end

          if move['comments']
            result += "\n" if result[-1] != "\n"
            result += convert_comments(move['comments'])
            i = 0
          end
        end
      }
      result
    end

    def convert_move(move)
      result = if move['color'] == 0
                 '▲'
               else
                 '△'
               end
      result += if move['to']
                  n2zen(move['to']['x']) + n2kan(move['to']['y'])
                elsif move['same']
                  '同　'
                else
                  raise "error??"
                end
      result += csa2kind(move['piece'])
      result += '成' if move['promote']
      result
    end

    def convert_special(special, index)
      result = "まで#{index+1}手"
      turn = index % 2 == 0 ? '後' : '先'

      if special == 'TORYO' || special =~ /ILLEGAL/
        result += "で#{turn}手の"
        result += case special
                  when "TORYO"          then "勝ち"
                  when "ILLEGAL_ACTION" then "反則勝ち"
                  when "ILLEGAL_MOVE"   then "反則負け"
                  end
      else
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

    def convert_board_piece(piece)
      result = ''

      if piece == {}
        result = ' ・'
      else
        result += if piece['color'] == 0
                    ' '
                  else
                    'v'
                  end
        result += csa2kind(piece['kind'])
      end

      result
    end

    def convert_motigoma(pieces)
      pieces.map do |piece, num|
        if num > 0
          csa2kind(piece) + n2kan(num)
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
  end
end
