module Jkf::Converter
  class Ki2
    def convert(jkf)
      hash = JSON.parse(jkf)

      result = ''
      result += convert_header(hash['header']) if hash['header']

      result
    end

    def convert_header(header)
      header.map { |(key, value)| "#{key}：#{value}\n" }.join
    end
  end
end
