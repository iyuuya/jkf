source 'https://rubygems.org'

gemspec

gem "rake", "~> 10.0"

group :development do
  gem "yard", require: false
  gem "redcarpet", require: false

  # NOTE: version should match HoundCi RuboCop version
  gem "rubocop", "= 0.29.1", require: false
  gem "guard-rubocop", require: false
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem "rspec", "~> 3.0", require: false
  gem "guard-rspec", require: false
end
