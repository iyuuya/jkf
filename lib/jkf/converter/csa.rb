module Jkf::Converter
  class Csa
    VERSION = '2.2'

    def convert(jkf)
      hash = if jkf.is_a?(Hash)
               jkf
             else
               JSON.parse(jkf)
             end

      result = version
      result += convert_information(hash['header']) if hash['header']
      result += convert_initial(hash['initial']) if hash['initial']
      result += convert_moves(hash['moves']) if hash['moves']
      result
    end

    def convert_information(header)
      result = ''
      result += 'N+' + (header.delete('先手') || header.delete('下手') || '') + "\n" if header['先手'] || header['下手']
      result += 'N-' + (header.delete('後手') || header.delete('上手') || '') + "\n" if header['後手'] || header['上手']
      header.each { |(k,v)| result += "$#{csa_header_key(k)}:#{v}\n" }
      result
    end

    def convert_initial(initial)
      result = ''
      data = initial['data']
      if initial['preset'] == 'OTHER'
        9.times { |y|
          line = "P#{y+1}"
          9.times { |x|
            piece = data['board'][8-x][y]
            line += if piece == {}
                       " * "
                     else
                       csa_color(piece['color']) + piece['kind']
                     end
          }
          result += line + "\n"
        }
      else
        result += 'PI'
        case initial['preset']
        when 'HIRATE'
        when 'KY' # 香落ち
          result += '11KY'
        when 'KY_R' # 右香落ち
          result += '91KY'
        when 'KA' # 角落ち
          result += '22KA'
        when 'HI' # 飛車落ち
          result += '82HI'
        when 'HIKY' # 飛香落ち
          result += '22HI11KY91KY'
        when '2' # 二枚落ち
          result += '82HI22KA'
        when '3' # 三枚落ち
          result += '82HI22KA91KY'
        when '4' # 四枚落ち
          result += '82HI22KA11KY91KY'
        when '5' # 五枚落ち
          result += '82HI22KA81KE11KY91KY'
        when '5_L' # 左五枚落ち
          result += '82HI22KA21KE11KY91KY'
        when '6' # 六枚落ち
          result += '82HI22KA21KE81KE11KY91KY'
        when '8' # 八枚落ち
          result += '82HI22KA31GI71GI21KE81KE11KY91KY'
        when '10' # 十枚落ち
          result += '82HI22KA41KI61KI31GI71GI21KE81KE11KY91KY'
        end
      end
      # 持駒
      if data['hands']
        sum = 0
        data['hands'][0].each_value { |n| sum += n }
        if sum > 0
          result += 'P+'
          data['hands'][0].to_a.reverse.each { |(k, v)| v.times { result += "00#{k}" } }
          result += "\n"
        end
        sum = 0
        data['hands'][1].each_value { |n| sum += n }
        if sum > 0
          result += 'P-'
          data['hands'][1].to_a.reverse.each { |(k, v)| v.times { result += "00#{k}" } }
          result += "\n"
        end
      end
      result += csa_color(data['color']) + "\n" if data['color']
      result
    end

    def convert_moves(moves)
      result = ''
      moves.each do |move|
        next if move == {}
        result += convert_move(move['move']) if move['move']
        result += convert_special(move['special'], move['color']) if move['special']
        if move['time']
          result += "," + convert_time(move['time'])
        elsif move['move'] || move['special']
          result += "\n"
        end
        result += convert_comments(move['comments']) if move['comments']
      end
      result
    end

    def convert_move(move)
      result = csa_color(move['color'])
      result += if move['from']
                  "#{move['from']['x']}#{move['from']['y']}"
                else
                  "00"
                end
      result += "#{move['to']['x']}#{move['to']['y']}"
      result += move['piece']
      result
    end

    def convert_special(special, color=nil)
      result = "%"
      result += csa_color(color) if color
      result += special
      result
    end

    def convert_time(time)
      sec = time['now']['m'] * 60 + time['now']['s']
      "T#{sec}\n"
    end

    def convert_comments(comments)
      comments.map { |comment| "'#{comment}" }.join("\n") + "\n"
    end

    protected

    def csa_color(color)
      color == 0 ? '+' : '-'
    end

    def version
      "V#{VERSION}\n"
    end

    def csa_header_key(key)
      {
        "棋戦"     => "EVENT",
        "場所"     => "SITE",
        "開始日時" => "START_TIME",
        "終了日時" => "END_TIME",
        "持ち時間" => "TIME_LIMIT",
      }[key] || key
    end
  end
end
