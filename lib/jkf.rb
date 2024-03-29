require 'kconv'
require_relative 'jkf/version'
require_relative 'jkf/parser'
require_relative 'jkf/converter'

# JSON Kifu Format
module Jkf
  # raise when unsupport file type
  class FileTypeError < StandardError; end

  class << self
    # ファイルからパースします。拡張子でフォーマットの判定をします。
    #
    # @param [String] filename
    #
    # @return [String] KIF, KI2, CSA, JKF(JSON)
    def parse_file(filename, encoding: 'Shift_JIS')
      parser = case ::File.extname(filename)
               when /kif/
                 ::Jkf::Parser::Kif.new
               when /ki2/
                 ::Jkf::Parser::Ki2.new
               when /csa/
                 ::Jkf::Parser::Csa.new
               when /jkf|json/
                 JSON
               else
                 raise FileTypeError
               end
      str = File.read(File.expand_path(filename), encoding: encoding).toutf8
      parser.parse(str)
    end

    # 文字列からパースします。各パーサでパースに試みて成功した場合結果を返します。
    #
    # @param [String] str
    #
    # @return [Hash] JKF
    def parse(str)
      parsers = [::Jkf::Parser::Kif.new, ::Jkf::Parser::Ki2.new, ::Jkf::Parser::Csa.new, JSON]

      result = nil
      parsers.each do |parser|
        begin
          result = parser.parse(str)
        rescue StandardError
          next
        end
        break
      end
      raise FileTypeError if result.nil?
      result
    end
  end
end
