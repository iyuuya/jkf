module Jkf
  module Converter
    class ConvertError < StandardError; end
  end
end

require 'json'
require 'jkf/converter/ki2'
require 'jkf/converter/kif'
