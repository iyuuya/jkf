source "https://rubygems.org"

gemspec

gem "rake"

group :development do
  gem "yard", require: false
  gem "redcarpet", require: false

  gem "rubocop", "~> 1.32.0", require: false
  gem "guard-rubocop", require: false
  gem "rubocop-rake", "~> 0.6.0", require: false
  gem "rubocop-rspec", "~> 2.12", require: false
end

group :test do
  gem "rspec", "~> 3.0", require: false
  gem "guard-rspec", require: false
  gem "simplecov", require: false
end
