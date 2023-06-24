module Jkf
  module Parser
    class ParseError < StandardError; end
  end
end

require_relative 'parser/base'
require_relative 'parser/kifuable'
require_relative 'parser/kif'
require_relative 'parser/ki2'
require_relative 'parser/csa'
