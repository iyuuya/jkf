# Jkf
[![Gem Version](https://badge.fury.io/rb/jkf.svg)](https://badge.fury.io/rb/jkf) [![Build Status](https://travis-ci.org/iyuuya/jkf.svg?branch=master)](https://travis-ci.org/iyuuya/jkf) [![Code Climate](https://codeclimate.com/github/iyuuya/jkf/badges/gpa.svg)](https://codeclimate.com/github/iyuuya/jkf) [![Test Coverage](https://codeclimate.com/github/iyuuya/jkf/badges/coverage.svg)](https://codeclimate.com/github/iyuuya/jkf/coverage) [![Inline docs](http://inch-ci.org/github/iyuuya/jkf.svg?branch=develop)](http://inch-ci.org/github/iyuuya/jkf)


jkf is json-kifu-format( https://github.com/na2hiro/json-kifu-format ) library for ruby.

### Feature

* KIF, KI2, CSA to JKF
* JKF to KIF, KI2, CSA

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jkf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jkf

## Usage

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

Bug reports and pull requests are welcome on GitHub at https://github.com/iyuuya/jkf.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

