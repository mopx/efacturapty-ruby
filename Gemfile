source "https://rubygems.org"

gemspec

group :development, :test do
  gem "rspec", "~> 3.13"
  gem "webmock", "~> 3"
end

# rubocop-rspec >= 2.21 requires Ruby >= 2.7; skip the whole group on 2.6
if RUBY_VERSION >= "2.7"
  group :lint do
    gem "rubocop", "~> 1.88.0", require: false
    gem "rubocop-rspec", "~> 3.4", require: false
  end
end
