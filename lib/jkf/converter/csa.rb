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
      result
    end

    def convert_information(header)
      result = ''
      result += 'N+' + (header.delete('先手') || header.delete('下手') || '') + "\n"
      result += 'N-' + (header.delete('後手') || header.delete('上手') || '') + "\n"
      header.each { |(k,v)| result += "$#{csa_header_key(k)}:#{v}\n" }
      result
    end

    protected

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
