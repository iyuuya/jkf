module Jkf
  # Define converter namespace
  module Converter
    # Convert error
    class ConvertError < StandardError; end
  end
end

require 'json'
require 'jkf/converter/base'
require 'jkf/converter/kifuable'
require 'jkf/converter/kif'
require 'jkf/converter/ki2'
require 'jkf/converter/csa'
