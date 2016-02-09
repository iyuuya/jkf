module Jkf
  module Parser
    class Kif < Parslet::Parser
      root :kifu

      rule(:kifu) { skipline.repeat.maybe >> header.repeat.maybe.as(:headers) }

      # Header
      rule(:header) {
        str("盤面回転").as(:kaiten) >> nl |
        turn.as(:te) >> str("手番") >> nl |
        match('[^：\r\n]').repeat.as(:key) >> str("：") >> nonl.repeat.maybe.as(:value) >> nl
      }
      rule(:turn) { match('[先後上下]') }

      # whitespace / nl / nonl
      rule(:nl) { newline.repeat(1) >> skipline.repeat.maybe }
      rule(:nonl) { match('[^\n]') }
      rule(:whitespace) { str(' ') | str("\t") }
      rule(:newline) { whitespace.repeat.maybe >> (match('\n') | match('\r\n?')) }
      rule(:skipline) { str('#') >> nonl.repeat.maybe >> newline }
    end
  end
end
