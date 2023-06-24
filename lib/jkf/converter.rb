module Jkf
  module Converter
    class ConvertError < StandardError; end
  end
end

require 'json'
require_relative 'converter/base'
require_relative 'converter/kifuable'
require_relative 'converter/kif'
require_relative 'converter/ki2'
require_relative 'converter/csa'
