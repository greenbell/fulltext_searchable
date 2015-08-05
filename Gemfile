source "http://rubygems.org"

if ENV['RAILS_VER'] == '3.0'
  gem "rails", "~> 3.0.5"
  gem "mysql2", "~> 0.2.6"
  gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'
  gem 'rails3_acts_as_paranoid', :git => 'git://github.com/greenbell/rails3_acts_as_paranoid.git'
elsif ENV['RAILS_VER'] == '3.2'
  gem "rails", "~> 3.2.0"
  gem "mysql2"
  gem 'will_paginate', "~> 3.0.4"
  if ENV['PARANOID'] == 'original'
    gem 'acts_as_paranoid'
  else
    gem 'rails3_acts_as_paranoid', :git => 'git://github.com/greenbell/rails3_acts_as_paranoid.git'
  end
else
  gem "rails", "~> 4.0"
  gem "mysql2"
  gem 'will_paginate'
  gem 'acts_as_paranoid', github: 'ActsAsParanoid/acts_as_paranoid'
end

gem "debugger", :platforms => [:mri_19, :mri_20]
gem "byebug", :platforms => :mri_21

gemspec
