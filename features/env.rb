$LOAD_PATH.unshift("#{__dir__}/../lib")
require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'bcrypt'
require 'mongoid'
require 'database_cleaner'


ENV['RACK_ENV'] = 'development'
Mongoid.load!(File.expand_path('../mongoid.yml', File.dirname(__FILE__)))



Capybara.default_driver = :poltergeist
Capybara.register_driver :poltergeist do |app|
  options = {
  :js_errors => true,
  :timeout => 120,
  :debug => false,
  :phantomjs_options => ['--load-images=no', '--disk-cache=false'],
  :inspector => true,
  }
  Capybara::Poltergeist::Driver.new(app, options)
end

Capybara.javascript_driver = :poltergeist
Capybara.app = Rack::Builder.parse_file(File.expand_path('config.ru')).first


Before do
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end