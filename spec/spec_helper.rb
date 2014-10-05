$LOAD_PATH.unshift("#{__dir__}/../lib")
require 'rspec'
require 'rack/test'
require 'mongoid'
require 'database_cleaner'

ENV['RACK_ENV'] = 'development'
Mongoid.load!(File.expand_path('../mongoid.yml', File.dirname(__FILE__)))
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end


  config.before :each do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.order = :random
  Kernel.srand config.seed
  config.include Rack::Test::Methods
end

