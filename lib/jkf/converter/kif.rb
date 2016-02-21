module Jkf::Converter
  class Kif
    def convert(jkf)
      hash = if jkf.is_a?(Hash)
               jkf
             else
               JSON.parse(jkf)
             end

      result = ''
      result += convert_header(hash['header']) if hash['header']
      result += convert_initial(hash['initial']) if hash['initial']
      result += convert_moves(hash['moves']) if hash['moves']

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

    def convert_moves(moves)
      result = "手数----指手---------消費時間--\n"
      moves.each_with_index { |move, i|
        if move['move']
          result_move = "%4d "%i
          result_move += convert_move(move['move'])
          result_move += convert_time(move['time']) if move['time']
          result_move += "\n"
          result += result_move
        end

        if move['comments']
          result += convert_comments(move['comments'])
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

    def convert_comments(comments)
      comments.map { |comment| "*#{comment}\n" }.join
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

    def ljust(str, n)
      len = 0
      str.each_codepoint { |codepoint| len += codepoint > 255 ? 2 : 1 }
      str + ' '*(n-len)
    end
  end
end
