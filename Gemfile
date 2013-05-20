source "http://rubygems.org"

if ENV['RAILS_VER'] == '3.0'
  gem "rails", "~> 3.0.5"
  gem "mysql2", "~> 0.2.6"
  group :development, :test do
    gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'
    gem 'rails3_acts_as_paranoid', :git => 'git://github.com/mshibuya/rails3_acts_as_paranoid.git'
  end
else
  gem "rails", "~> 3.0"
  gem "mysql2"
  group :development, :test do
    gem 'will_paginate'
    gem 'acts_as_paranoid', :github => 'goncalossilva/rails3_acts_as_paranoid', :branch => 'rails3.2'
  end
end

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
end

