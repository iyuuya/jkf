require 'benchmark/ips'
require_relative 'lib/jkf'

Benchmark.ips do |x|
  x.report('parse') do
    Dir['spec/*fixtures/**/*'].each do |file|
      Jkf.parse_file(file)
    rescue Jkf::FileTypeError, Jkf::Parser::ParseError
      # okay
    end
  end
end
