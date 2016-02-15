module Jkf::Converter
  class Kif
    def convert(jkf)
      hash = JSON.parse(jkf)

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

    # TODO: implements
    def convert_initial(initial)
      result = ''
    end

    def convert_moves(moves)
      result = ''
    end
  end
end
