module Jkf
  module Parser
    class ParseError < StandardError; end
  end
end

require 'jkf/parser/base'
require 'jkf/parser/kif'
require 'jkf/parser/ki2'
require 'jkf/parser/csa'
