source "https://rubygems.org"

gemspec

group :development, :test do
  gem "rspec", "~> 3.13"
  gem "webmock", "~> 3"
end

# rubocop requires Ruby >= 2.7 — only install for linting, not on the 2.6 test run
group :lint do
  gem "rubocop", "~> 1.70", require: false
  gem "rubocop-rspec", "~> 3.4", require: false
end
