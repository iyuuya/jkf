# Jkf
[![Gem Version](https://badge.fury.io/rb/jkf.svg)](https://badge.fury.io/rb/jkf) [![Build Status](https://travis-ci.org/iyuuya/jkf.svg?branch=master)](https://travis-ci.org/iyuuya/jkf) [![Code Climate](https://codeclimate.com/github/iyuuya/jkf/badges/gpa.svg)](https://codeclimate.com/github/iyuuya/jkf) [![Test Coverage](https://codeclimate.com/github/iyuuya/jkf/badges/coverage.svg)](https://codeclimate.com/github/iyuuya/jkf/coverage) [![Inline docs](http://inch-ci.org/github/iyuuya/jkf.svg?branch=develop)](http://inch-ci.org/github/iyuuya/jkf)

jkfはJSON棋譜フォーマット( https://github.com/na2hiro/json-kifu-format )をRubyに移植したものです。
KIF, KI2, CSAをパースしJKFへ変換、JKFからKIF, KI2, CSAへの変換に対応しています。

## Installation

アプリケーションにインストールする場合(bundlerを使用する場合)、Gemfileに以下のように記述してください。

```ruby
gem 'jkf'
```

さらにbundleコマンドを実行することでインストールできます。

    $ bundle

または、gem installコマンドを使って直接インストールすることもできます。

    $ gem install jkf

## Usage

KIF, KI2, CSAそれぞれParserとConverterが用意してあります。

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

`parser#parse(str)`でjkfへの変換、`#convert(jkf)`でjkfから各フォーマットへ変換できます。

```ruby
jkf = kif_parser.parse(kif_str) #=> Hash
jkf = ki2_parser.parse(ki2_str) #=> Hash
jkf = csa_parser.parse(csa_str) #=> Hash
```

```ruby
kif = kif_converter.parse(jkf) #=> String
ki2 = ki2_converter.parse(jkf) #=> String
csa = csa_converter.parse(jkf) #=> String
```

## Contributing

バグレポートやプルリクエストはGithubでよろしくお願いします。
https://github.com/iyuuya/jkf.

## License

ライセンスはMITです。
[MIT License](http://opensource.org/licenses/MIT).

