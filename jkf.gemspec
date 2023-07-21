lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jkf/version'

Gem::Specification.new do |spec|
  spec.name = 'jkf'
  spec.version = Jkf::VERSION
  spec.authors = ['iyuuya', 'gemmaro']
  spec.email = ['i.yuuya@gmail.com', 'gemmaro.dev@gmail.com']

  spec.summary = 'Shogi formats parser and converter'
  spec.description = 'The jkf gem provides parsers and converters (generaters) for several shogi formats.'
  spec.homepage = 'https://github.com/iyuuya/jkf'
  spec.license = 'MIT'

  spec.required_ruby_version = '>= 3.0'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.metadata = {
    'rubygems_mfa_required' => true,
    'documentation_uri' => 'https://www.rubydoc.info/gems/jkf'
  }
end
