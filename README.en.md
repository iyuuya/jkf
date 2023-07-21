# jkf gem

[![Gem
Version](https://badge.fury.io/rb/jkf.svg)](https://badge.fury.io/rb/jkf)
[![Build
Status](https://travis-ci.org/iyuuya/jkf.svg?branch=master)](https://travis-ci.org/iyuuya/jkf)
[![CI](https://github.com/iyuuya/jkf/actions/workflows/ci.yml/badge.svg)](https://github.com/iyuuya/jkf/actions/workflows/ci.yml)

The jkf gem is a Ruby port of [json-kifu-format (JKF)][jkf].
It supports both of the conversion from KIF (see [棋譜ファイル KIF 形式][kakinoki]),
KI2, or CSA (see [CSA標準棋譜ファイル形式][csa]) to JKF, and the one from JKF to KIF,
KI2, or CSA.

[csa]: http://www2.computer-shogi.org/protocol/record_v22.html
[jkf]:
https://github.com/na2hiro/Kifu-for-JS/tree/master/packages/json-kifu-format
[kakinoki]: http://kakinoki.o.oo7.jp/kif_format.html

## Installation

If you install this gem to your application (with [Bundler][bundler]), add
this to `Gemfile`.

[bundler]: https://bundler.io/

```ruby
gem 'jkf'
```

Then run `bundle` to install this gem.

Or directly install with `gem install` command.

## Usage

This gem has the parser {Jkf::Parser} and the converter {Jkf::Converter} for
each formats: KIF, KI2, and CSA.

```ruby
kif_parser = Jkf::Parser::Kif.new
ki2_parser = Jkf::Parser::Ki2.new
csa_parser = Jkf::Parser::Csa.new
```

```ruby
kif_converter = Jkf::Converter::Kif.new
ki2_converter = Jkf::Converter::Ki2.new
csa_converter = Jkf::Converter::Csa.new
```

{Jkf::Parser::Base#parse} to convert into JKF.
{Jkf::Converter::Base#convert} to convert into each formats from JKF.

```ruby
jkf = kif_parser.parse(kif_str) #=> Hash
jkf = ki2_parser.parse(ki2_str) #=> Hash
jkf = csa_parser.parse(csa_str) #=> Hash
```

```ruby
kif = kif_converter.convert(jkf) #=> String
ki2 = ki2_converter.convert(jkf) #=> String
csa = csa_converter.convert(jkf) #=> String
```

## Contributing

Feel free to report bugs or send pull requests at [the GitHub
repository][repo].

[repo]: https://github.com/iyuuya/jkf

If you work on Guix, run tests by `guix shell`.

## License

This gem is provided under the [MIT License][mit].

[mit]: http://opensource.org/licenses/MIT
