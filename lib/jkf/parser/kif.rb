module Jkf
  module Parser
    class Kif < Parslet::Parser
      root :kifu

      rule(:kifu) { skipline.repeat.maybe }

      # whitespace / nl / nonl
      rule(:nl) { newline.repeat(1) >> skipline.repeat.maybe }
      rule(:nonl) { match('[^\n]') }
      rule(:whitespace) { match('\s') }# str(' ') | str("\t") }
      rule(:newline) { whitespace.repeat.maybe >> (match('\n') | match('\r\n?')) }
      rule(:skipline) { str('#') >> nonl.repeat.maybe >> newline }
    end
  end
end
