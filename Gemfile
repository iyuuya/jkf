source "https://rubygems.org"

gemspec

gem "rake"

group :development do
  gem "yard", require: false
  gem "redcarpet", require: false

  gem "rubocop", "~> 0.37.2", require: false
  gem "guard-rubocop", require: false
end

group :test do
  gem "codeclimate-test-reporter", require: nil
  gem "rspec", "~> 3.0", require: false
  gem "guard-rspec", require: false
end
