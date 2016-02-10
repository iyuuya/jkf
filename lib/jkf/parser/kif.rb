# coding: utf-8

module Jkf
  module Parser
    class Kif < Parslet::Parser
      root :kifu

      rule(:kifu) { skipline.repeat >> header.repeat.as(:headers) >> initial_board.maybe.as(:initial_board) >> header.repeat.as(:headers2) >> split.maybe >> moves.as(:moves) >> fork.repeat.as(:forks) >> nl.maybe }

      # Header
      rule(:header) {
        str('盤面回転').as(:kaiten) >> nl |
        turn.as(:te) >> str('手番') >> nl |
        match('[^：\r\n]').repeat.as(:key) >> str('：') >> nonl.repeat.as(:value) >> nl
      }
      rule(:turn) { match('[先後上下]') }

      # InitialBoard
      rule(:initial_board) {
        (space >> nonl.repeat >> nl).maybe >>
        (str('+') >> nonl.repeat >> nl).maybe >>
        ikkatsu_line.repeat(1).as(:lines) >>
        (str('+') >> nonl.repeat >> nl).maybe
      }
      rule(:ikkatsu_line) { str('|') >> masu.repeat(1).as(:masu) >> str('|') >> nonl.repeat(1) >> nl }
      rule(:masu) {
        str(' ・').as(:empty) |
        teban.as(:c) >> piece.as(:k)
      }
      rule(:teban) {
        (space | str('+') | str('^')) |
        (str('v') | str('V'))
      }

      # Split
      rule(:split) { str('手数----指手--') >> str('-------消費時間--').maybe >> nl }

      # Moves
      rule(:moves) { first_board.as(:hd) >> split.maybe >> move.repeat.as(:tl) >> result.maybe }
      rule(:first_board) { comments.as(:c) >> pointer.maybe }
      rule(:move) { line.as(:line) >> comments.as(:c) >> pointer.maybe }
      rule(:pointer) { str('&') >> nonl.repeat >> nl }
      rule(:line) { spaces? >> te >> spaces? >> (fugou.as(:fugou) >> from.as(:from) | match('[^\r\n ]').repeat.as(:spe)).as(:move) >> spaces? >> time.maybe.as(:time) >> str('+').maybe >> nl.maybe }
      rule(:te) { match('\d').repeat(1) }
      rule(:fugou) { place.as(:pl) >> piece.as(:pi) >> str('成').maybe.as(:pro) }
      rule(:place) { num.as(:x) >> numkan.as(:y) | str('同　') }
      rule(:num) { match('[１２３４５６７８９]').as(:n) }
      rule(:numkan) { match('[一二三四五六七八九]').as(:n) }

      rule(:piece) { str('成').maybe.as(:pro) >> match('[歩香桂銀金角飛王玉と杏圭全馬竜龍]').as(:p) }

      rule(:from) { str('打') | str('(') >> match('[1-9]').as(:x) >> match('[1-9]').as(:y) >> str(')') }

      rule(:time) { str('(') >> spaces? >> ms.as(:now) >> str('/') >> hms.as(:total) >> str(')') }
      rule(:hms) { match('\d').repeat.as(:h) >> str(':') >> match('\d').repeat.as(:m) >> str(':') >> match('\d').repeat.as(:s) }
      rule(:ms) { match('\d').repeat.as(:m) >> str(':') >> match('\d').repeat.as(:s) }

      rule(:comment) {
        str('*') >> nonl.repeat.as(:comm) |
        str('&') >> nonl.repeat.as(:annotation)
      }
      rule(:comments) {
        (comment >> nl.maybe).repeat
      }

      rule(:result) {
        str('まで') >> match('\d').repeat >> str('手') >> (
          str('で') >> turn.as(:win) >> str('手の') >> (str('勝ち') | str('反則') >> (str('勝ち') | str('負け')).as(:res)).as(:res) |
          str('で時間切れにより') >> turn.as(:win) >> str('手の勝ち') |
          str('で中断') |
          str('で持将棋') |
          str('で千日手') |
          str('で').maybe >> str('詰') >> str('み').maybe |
          str('で不詰')
        ).as(:res) >> nl.maybe
      }

      # Fork
      rule(:fork) { str('変化：') >> spaces? >> match('\d').repeat(1).as(:te) >> str('手') >> nl >> moves.as(:as) }

      # whitespace / nl / nonl
      rule(:nl) { newline.repeat(1) >> skipline.repeat }
      rule(:nonl) { match('[^\n]') }
      rule(:whitespace) { space | str("\t") }
      rule(:newline) { whitespace.repeat >> (str("\n") | str("\r") >> str("\n").maybe) }
      rule(:skipline) { str('#') >> nonl.repeat >> newline }
      rule(:space) { str(' ') }
      rule(:spaces) { space.repeat(1) }
      rule(:spaces?) { spaces.maybe }
    end
  end
end
