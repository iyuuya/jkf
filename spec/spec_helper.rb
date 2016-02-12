$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jkf'

def fixtures(type)
  Dir[File.expand_path("../fixtures/#{type}/**", __FILE__)]
end
