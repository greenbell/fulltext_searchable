# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require 'cover_me'
CoverMe.config do |c|
  c.at_exit = Proc.new {}
  c.file_pattern = /(#{c.project.root}\/app\/.+\.rb|#{c.project.root}\/lib\/.+\.rb)/ix
end

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"

require "factory_girl"
require "faker"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec
#  config.fixture_path = "#{File.dirname(__FILE__)}/fixtures"
#  config.global_fixtures = :all
  require "database_cleaner"
  config.before(:suite) do
    DatabaseCleaner.app_root = "#{File.dirname(__FILE__)}/dummy/"
    DatabaseCleaner.strategy = :truncation
  end
  config.before(:each){ DatabaseCleaner.clean }
  # filtering
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
