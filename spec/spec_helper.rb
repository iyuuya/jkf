require 'kconv'
require 'pry'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jkf'

module ExtendHelper
  def fixtures(type)
    Dir[File.expand_path("../fixtures/#{type}/**", __FILE__)]
  end
end

module IncludeHelper
  def pos(x, y)
    { 'x' => x, 'y' => y }
  end

  def fixtures(type)
    Dir[File.expand_path("../fixtures/#{type}/**", __FILE__)]
  end
end

RSpec.configure do |config|
  config.extend ExtendHelper
  config.include IncludeHelper
end
