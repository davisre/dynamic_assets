ENV["RAILS_ENV"] ||= 'test'

require 'dummy_rails_app/config/environment'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec/rails'

require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

require 'dynamic_assets'

# PENDING: not sure why these aren't auto-required
require 'app/helpers/dynamic_assets_helpers'
require 'config/routes'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end
