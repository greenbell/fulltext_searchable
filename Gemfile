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

group :development, :test do
  gem "debugger"
end

gemspec
