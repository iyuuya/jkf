require "kconv"
require "jkf/version"
require "jkf/parser"
require "jkf/converter"

module Jkf
  class FileTypeError < StandardError; end

  class << self
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
               end
      str = File.read(File.expand_path(filename), encoding: encoding).toutf8
      parser.parse(str)
    end

    def parse(str)
      parsers = [::Jkf::Parser::Kif.new, ::Jkf::Parser::Ki2.new, ::Jkf::Parser::Csa.new, JSON]

      result = nil
      parsers.each do |parser|
        begin
          result = parser.parse(str)
        rescue
          next
        end
        break
      end
      raise FileTypeError if result.nil?
      result
    end
  end
end
