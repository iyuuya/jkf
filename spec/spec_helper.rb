require "codeclimate-test-reporter"
SimpleCov.start do
  add_filter "/vendor"
  add_filter ".bundle"

  formatter SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      CodeClimate::TestReporter::Formatter
    ]
  )
end

require "kconv"
require "pry"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "jkf"

module ExtendHelper
  def fixtures(type)
    Dir[File.expand_path("../fixtures/#{type}/**", __FILE__)]
  end

  def error_fixtures(type)
    Dir[File.expand_path("../error_fixtures/#{type}/**", __FILE__)]
  end
end

module IncludeHelper
  def pos(x, y)
    { "x" => x, "y" => y }
  end

  def hms(h, m, s)
    { "h" => h, "m" => m, "s" => s }
  end

  def ms(m, s)
    { "m" => m, "s" => s }
  end

  def fixtures(type)
    Dir[File.expand_path("../fixtures/#{type}/**", __FILE__)]
  end

  def error_fixtures(type)
    Dir[File.expand_path("../error_fixtures/#{type}/**", __FILE__)]
  end
end

RSpec.configure do |config|
  config.extend ExtendHelper
  config.include IncludeHelper
end
