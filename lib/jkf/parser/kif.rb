module Jkf
  module Parser
    class Kif < Parslet::Parser
      root :kifu

      rule(:kifu) { skipline.repeat.maybe >> header.repeat.maybe.as(:headers) >> initial_board.maybe.as(:initial_board) >> header.repeat.maybe.as(:headers2) >> split.maybe }

      # Header
      rule(:header) {
        str("盤面回転").as(:kaiten) >> nl |
        turn.as(:te) >> str("手番") >> nl |
        match('[^：\r\n]').repeat.as(:key) >> str("：") >> nonl.repeat.maybe.as(:value) >> nl
      }
      rule(:turn) { match('[先後上下]') }

      # InitialBoard
      rule(:initial_board) {
        (str(" ") >> nonl.repeat.maybe >> nl).maybe >>
        (str("+") >> nonl.repeat.maybe >> nl).maybe >>
        ikkatsu_line.repeat(1).as(:lines) >>
        (str("+") >> nonl.repeat.maybe >> nl).maybe
      }
      rule(:ikkatsu_line) { str("|") >> masu.repeat(1).as(:masu) >> str("|") >> nonl.repeat(1) >> nl }
      rule(:masu) {
        str(" ・").as(:empty) |
        teban.as(:c) >> piece.as(:k)
      }
      rule(:teban) {
        (str(' ') | str('+') | str('^')) |
        (str('v') | str('V'))
      }

      # Split
      rule(:split) { str("手数----指手--") >> str("-------消費時間--").maybe >> nl }

      # Common
      rule(:piece) { str("成").maybe.as(:pro) >> match('[歩香桂銀金角飛王玉と杏圭全馬竜龍]').as(:p) }

      # whitespace / nl / nonl
      rule(:nl) { newline.repeat(1) >> skipline.repeat.maybe }
      rule(:nonl) { match('[^\n]') }
      rule(:whitespace) { str(' ') | str("\t") }
      rule(:newline) { whitespace.repeat.maybe >> (match('\n') | match('\r\n?')) }
      rule(:skipline) { str('#') >> nonl.repeat.maybe >> newline }
    end
  end
end
