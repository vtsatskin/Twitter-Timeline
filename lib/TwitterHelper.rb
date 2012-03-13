require 'grackle'
# TODO: possibly have this extend Grackle::client
class TwitterHelper
  TWEET_BATCH_SIZE = 200 # The number of tweets to query for at a time, current API limit is 200

  def initialize
    @client = Grackle::Client.new
  end

  def client
    @client
  end

  # Attempts to get all tweets for specified twitter screen name
  # Uses Twitter REST API: https://dev.twitter.com/docs/api/1/get/statuses/user_timeline
  # Limited to a maximum of 3200 tweets due to Twitter API
  def retrieve_all_tweets_for screen_name, since = nil
    throw :empty_screen_name if screen_name.empty?

    tweets = []
    page = 1

    begin
      while !(res = @client.statuses.user_timeline.json?({:screen_name => screen_name, :count => TWEET_BATCH_SIZE, :page => page, :trim_user => true, :include_rts => false, :since_id => since ? since : 1})).empty?
        tweets += res
        page += 1
      end
    rescue Grackle::TwitterError => e
      puts "number of tweets returned: #{tweets.count}"
      parse_twitter_error e
    end
    tweets
  end

  def tweet_count_for screen_name
    throw :empty_screen_name if screen_name.empty?

    begin
      result = @client.users.show.json? :screen_name => screen_name
      count = result.statuses_count
    rescue Grackle::TwitterError => e
      parse_twitter_error e
    end

    count
  end

  def retrieve_user screen_name
    throw :empty_screen_name if screen_name.empty?

    begin
      result = @client.users.show.json? :screen_name => screen_name
    rescue Grackle::TwitterError => e
      parse_twitter_error e
    end
  end

  private

  def parse_twitter_error exception
    throw :screen_name_not_found if exception.status == 404
    throw :twitter_over_capacity if exception.message.match "Unable to decode response: 756"
    throw :rate_limit_reached if exception.status == 400 && exception.message.match("Rate limit exceeded")
    throw exception
  end
end