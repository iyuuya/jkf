# Jkf
[![Gem
Version](https://badge.fury.io/rb/jkf.svg)](https://badge.fury.io/rb/jkf)
[![Build
Status](https://travis-ci.org/iyuuya/jkf.svg?branch=master)](https://travis-ci.org/iyuuya/jkf)
[![CI](https://github.com/iyuuya/jkf/actions/workflows/ci.yml/badge.svg)](https://github.com/iyuuya/jkf/actions/workflows/ci.yml)

jkf is a Ruby port of [json-kifu-format][jkf].
It supports both of the conversion from KIF, KI2, or CSA to jkf, and the one
from jkf to KIF, KI2, or CSA.

[jkf]:https://github.com/na2hiro/Kifu-for-JS/tree/master/packages/json-kifu-format

## Installation

If you install this gem to your application (with Bundler), add this to
Gemfile.

```ruby
gem 'jkf'
```

Then run bundle to install this gem.

    $ bundle

Or directly install with gem install command.

    $ gem install jkf

## Usage

This gem has the Parser and the Converter for each formats: KIF, KI2, and
CSA.

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

`parser#parse(str)` to convert into jkf.
`#convert(jkf)` to convert into each formats from jkf.

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

Feel free to report bugs or send pull requests at
[GitHub](https://github.com/iyuuya/jkf).

If you work on Guix, run tests by `guix shell`.

## License

This gem is licensed under the [MIT
License](http://opensource.org/licenses/MIT).

