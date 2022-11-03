require "simplecov"

SimpleCov.start

require "kconv"
require "pry"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "jkf"
require "jkf/model"
require "jkf/model/color"
require "jkf/model/relative_string"
require "jkf/model/initial_preset_string"
require "jkf/model/place_format"

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
