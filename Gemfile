source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.5"

# Core Rails gems
gem "rails", "~> 8.0.0"
gem "sassc-rails"
gem "sprockets-rails"
gem "sqlite3", "~> 2.0"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bootsnap", ">= 1.4.4", require: false

# Markdown processing
gem "redcarpet", "~> 3.6"
gem "rouge", "~> 4.1"

# UI and styling
gem "bootstrap", "~> 5.2"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console", ">= 4.1.0"
  gem "listen", "~> 3.3"
  gem "spring"
end