module Jkf::Converter
  class Ki2
    def convert(jkf)
      hash = if jkf.is_a?(Hash)
               jkf
             else
               JSON.parse(jkf)
             end
      @forks = []

      players_flag = :sengo
      hash['header'] && hash['header'].keys.find { |key| key =~ /[上下]手/ } && players_flag = :uwasimo
      @players =  if players_flag == :uwasimo
                    ['下', '上']
                  else
                    ['先', '後']
                  end

      result = ''
      result += convert_header(hash['header']) if hash['header']
      result += convert_initial(hash['initial']) if hash['initial']
      result += convert_moves(hash['moves']) if hash['moves']
      if @forks.size > 0
        result += "\n"
        result += @forks.join("\n")
      end

      result
    end

    def convert_header(header)
      header.map { |(key, value)| "#{key}：#{value}\n" }.join
    end

    def convert_initial(initial)
      result = ''
      result += "手合割：#{preset2str(initial["preset"])}\n" if initial["preset"] != "OTHER"

      data = initial["data"]

      if data
        if data['color'] == 0
          result += "#{@players[0]}手番\n"
        elsif data['color'] == 1
          result += "#{@players[1]}手番\n"
        end

        if data['hands']
          if data['hands'][0]
            result += "#{@players[0]}手の持駒："
            result += convert_motigoma(data['hands'][0])
          end
          if data['hands'][1]
            result += "#{@players[1]}手の持駒："
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
      result = "\n"
      i = 0
      before_split = ''
      moves.each_with_index { |move, j|
        if move['special']
          result += "\n"
          # first_board+speical分を引く(-2)
          result += convert_special(move['special'], j-2+idx) if move['special']
        else
          result += before_split
          if move['move']
            result_move = convert_move(move['move'])
            i += 1
            before_split = if i % 6 == 0
                             "\n"
                           else
                             result_move.size == 4 ? " "*4 : " "*2
                           end
            result += result_move
          end

          if move['comments']
            result += "\n" if result[-1] != "\n"
            result += convert_comments(move['comments'])
            i = 0
          end

          @forks.unshift convert_forks(move['forks'], j+idx) if move['forks']
        end
      }
      result
    end

    def convert_move(move)
      result = move['color'] == 0 ? '▲' : '△'
      result += if move['to']
                  n2zen(move['to']['x']) + n2kan(move['to']['y'])
                elsif move['same']
                  '同　'
                else
                  raise "error??"
                end
      result += csa2kind(move['piece'])
      result += '成' if move['promote']
      result += csa2relative(move['relative']) if move['relative']
      result
    end

    def convert_special(special, index)
      result = "まで#{index+1}手"

      if special == 'TORYO' || special =~ /ILLEGAL/
        turn = @players[index % 2]
        result += "で#{turn}手の"
        result += case special
                  when "TORYO"          then "勝ち"
                  when "ILLEGAL_ACTION" then "反則勝ち"
                  when "ILLEGAL_MOVE"   then "反則負け"
                  end
      else
        turn = @players[(index+1) % 2]
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
      result = "変化：%4d手"%[index]
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
      pieces.to_a.reverse.map do |(piece, num)|
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

    def csa2relative(relative)
      case relative
      when 'L' then '左'
      when 'C' then '直'
      when 'R' then '右'
      when 'U' then '上'
      when 'M' then '寄'
      when 'D' then '引'
      when 'H' then '打'
      else
        ''
      end
    end
  end
end
