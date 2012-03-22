# webserver.rb
APP_ENV ||= 'development'

require 'sinatra'
require 'haml'
require 'json'
require './lib/TwitterHelper.rb'
require './config/mongodb.rb'

set :server, :thin
set :haml, :format => :html5, :layout => :default
enable :reload_templates if APP_ENV == 'development'
enable :static
set :static_cache_control, [:public, :max_age => 300]

get '/' do
  UserMapReduce.run
  @users = UserMap.all
  haml :index
end

get '/user/:screen_name' do
  screen_name = params[:screen_name]
  DateMapReduce.run screen_name
  @tweets = Tweet.where(:user_screen_name => screen_name).all
  @years = DateMap.get_distinct_field :year, :screen_name => screen_name
  @years.sort!.reverse!

  haml :user
end

get '/user/:screen_name/year/:year/months' do
  content_type :json
  months = DateMap.get_distinct_field :month, :screen_name => params[:screen_name], :year => params[:year].to_i
  months.sort.to_json
end

get '/user/:screen_name/year/:year/month/:month/days' do
  content_type :json
  days = DateMap.find_by :screen_name => params[:screen_name], :year => params[:year].to_i, :month => params[:month].to_i
  days.to_json
end

post '/user/:screen_name/tweets_for_date' do
  content_type :json
  datemap = DateMap.find_by({
    :screen_name => params['screen_name'],
    :day => params['day'].to_i,
    :month => params['month'].to_i,
    :year => params['year'].to_i,
  }).first
  tweet_ids = datemap.value['tweet_ids']
  tweets = Tweet.where({:user_screen_name => params[:screen_name], :tweet_id => tweet_ids}).sort({:created_at => -1})
  tweets.to_json
end

# Queues a tweet scrapping for a Twitter user
# This can take a long time, do not wait for finish
post '/fetch_tweets' do
  if screen_name = params[:screen_name]
    catch(:empty_screen_name) { [500, "Screen name cannot be blank"] }
    catch(:twitter_over_capacity) { [500, "Twitter is over capacity"] }
    catch(:rate_limit_reached) { [500, "Rate limit reached"] }
    
    tweets = Tweet.store_tweets_in_batches_for screen_name
    "Tweets for #{screen_name} successfully gathered (#{tweets.count})"
  else
    [500, "No screen name"]
  end
end