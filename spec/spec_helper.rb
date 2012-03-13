APP_ENV = 'test'
require 'rspec'
require 'rack/test'
require 'database_cleaner'
require_relative '../webserver.rb'

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods

  conf.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  conf.before(:each) do
    DatabaseCleaner.start
  end

  conf.after(:each) do
    DatabaseCleaner.clean
  end
end