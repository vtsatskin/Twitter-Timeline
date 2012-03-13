# webserver.rb
APP_ENV ||= 'development'

require 'sinatra'
require 'haml'
require './lib/TwitterHelper.rb'
require './config/mongodb.rb'

twitter = Grackle::Client.new

get '/' do
  'Hello world!'
end