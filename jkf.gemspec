# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jkf/version"

Gem::Specification.new do |spec|
  spec.name = "jkf"
  spec.version = Jkf::VERSION
  spec.authors = ["iyuuya"]
  spec.email = ["i.yuuya@gmail.com"]

  spec.summary = "jkf/csa/kif/ki2 parser and converter"
  spec.description = "converter/parser of records of shogi"
  spec.homepage = "https://github.com/iyuuya/jkf"
  spec.license = "MIT"

  spec.required_ruby_version = '>= 2.7'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.add_dependency "parslet", "~> 2.0"
end
