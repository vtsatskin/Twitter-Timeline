# webserver.rb
APP_ENV ||= 'development'

require 'sinatra'
require 'haml'
require './lib/TwitterHelper.rb'
require './config/mongodb.rb'

get '/' do
  'Hello world!'
end

# Queues a tweet scrapping for a Twitter user
# This can take a long time, do not wait for finish
post '/fetch_tweets' do
  
end