source "http://rubygems.org"

if ENV['RAILS_VER'] == '3.0'
  gem "rails", "~> 3.0.5"
  gem "mysql2", "~> 0.2.6"
  gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'
else
  gem "rails", "~> 3.0"
  gem "mysql2"
  gem 'will_paginate', "~> 3.0.4"
end

if ENV['PARANOID'] == 'original'
  gem 'acts_as_paranoid'
else
  gem 'rails3_acts_as_paranoid', :git => 'git://github.com/mshibuya/rails3_acts_as_paranoid.git'
end
gem "debugger"

gemspec
