# Jkf
[![Gem Version](https://badge.fury.io/rb/jkf.svg)](https://badge.fury.io/rb/jkf) [![Build Status](https://travis-ci.org/iyuuya/jkf.svg?branch=master)](https://travis-ci.org/iyuuya/jkf) [![CI](https://github.com/iyuuya/jkf/actions/workflows/ci.yml/badge.svg)](https://github.com/iyuuya/jkf/actions/workflows/ci.yml) [![Inline docs](http://inch-ci.org/github/iyuuya/jkf.svg?branch=develop)](http://inch-ci.org/github/iyuuya/jkf)

jkfは[JSON棋譜フォーマット (JKF)][jkf]をRubyに移植したものです。
KIF, KI2, CSAをパースしJKFへ変換、JKFからKIF, KI2, CSAへの変換に対応しています。

[jkf]: https://github.com/na2hiro/Kifu-for-JS/tree/master/packages/json-kifu-format

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
kif = kif_converter.convert(jkf) #=> String
ki2 = ki2_converter.convert(jkf) #=> String
csa = csa_converter.convert(jkf) #=> String
```

## Contributing

バグレポートやプルリクエストはGithubでよろしくお願いします。
https://github.com/iyuuya/jkf.

Guixで開発されている場合は`guix shell`で`rake test`によるテスト実行ができます。

## License

ライセンスはMITです。
[MIT License](http://opensource.org/licenses/MIT).

