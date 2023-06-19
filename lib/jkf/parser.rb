module Jkf
  # Define parser namespace
  module Parser
    # Parse error
    class ParseError < StandardError; end
  end
end

require 'jkf/parser/base'
require 'jkf/parser/kifuable'
require 'jkf/parser/kif'
require 'jkf/parser/ki2'
require 'jkf/parser/csa'
