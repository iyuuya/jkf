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
      moves.each { |move|
        if move['move']
          result_move = convert_move(move['move'])
          i += 1
          if i % 6 == 0
            result_move += "\n"
          else
            result_move += result_move.size == 4 ? " "*4 : " "*2
          end
          result += result_move
        end

        if move['comments']
          result += "\n" if result[-1] != "\n"
          result += convert_comments(move['comments'])
          i = 0
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
