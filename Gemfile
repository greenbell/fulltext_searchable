source "http://rubygems.org"

gem "rails", "~> 3.0"
gem "mysql2"
gem "htmlentities"
gem "fulltext_searchable", :path => './'

group :development, :test do
  gem "rspec-rails"
  gem "factory_girl", "~> 1.3"
  gem "faker"
  gem "cover_me"
  gem "bundler"
  gem "jeweler"
  gem "capybara"
  gem "rdoc"
  gem "database_cleaner"
  if RUBY_VERSION >= '1.9'
    gem "debugger"
  else
    gem "ruby-debug"
  end
  gem 'will_paginate'
  gem 'acts_as_paranoid', :github => 'goncalossilva/rails3_acts_as_paranoid', :branch => 'rails3.2'
end

