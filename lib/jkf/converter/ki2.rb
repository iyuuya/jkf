module Jkf
  module Converter
    # KI2 Converter
    class Ki2 < Base
      include Kifuable

      protected

      def convert_root(jkf)
        reset!
        setup_players!(jkf)

        result = ''
        result += convert_header(jkf['header']) if jkf['header']
        result += convert_initial(jkf['initial']) if jkf['initial']
        result += @header2.join + "\n"
        result += convert_moves(jkf['moves']) if jkf['moves']
        unless @forks.empty?
          result += "\n"
          result += @forks.join("\n")
        end

        result
      end

      def convert_header(header)
        header.map do |(key, value)|
          result = add_header(key, value)
          if key =~ /\A[先後上下]手\Z/
            nil
          else
            result
          end
        end.compact.join
      end

      def add_header(key, value)
        result = "#{key}：#{value}\n"
        if key =~ /\A[先後上下]手\Z/
          if key =~ /[先下]/
            @header2.unshift result
          else
            @header2 << result
          end
        end
        result
      end

      def convert_moves(moves, idx = 0)
        result = ''
        j = 0
        before_split = ''
        moves.each_with_index do |move, i|
          if move['special']
            # first_board+speical分を引く(-2)
            result += convert_special_and_split(move, i + idx - 2)
          else
            result += before_split
            if move['move']
              j += 1
              result_move, before_split = convert_move_and_split(move, j)
              result += result_move
            end

            if move['comments']
              unless result.end_with?("\n") || result.empty?
                result += "\n"
                before_split = ''
                j = 0
              end
              result += convert_comments(move['comments'])
            end

            @forks.unshift convert_forks(move['forks'], i + idx) if move['forks']
          end
        end
        result
      end

      def convert_special_and_split(hash, index)
        "\n" + convert_special(hash['special'], index)
      end

      def convert_move_and_split(move, num)
        result = convert_move(move['move'])
        split = if num % 6 == 0
                  "\n"
                else
                  result.size == 4 ? ' ' * 4 : ' ' * 2
                end
        [result, split]
      end

      def convert_move(move)
        result = move['color'] == 0 ? '▲' : '△'
        result += convert_piece_with_pos(move)
        result += csa2relative(move['relative']) if move['relative']
        result
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
end
