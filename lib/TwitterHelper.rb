require 'grackle'
# TODO: possibly have this extend Grackle::client
module TwitterHelper
  TWEET_BATCH_SIZE = 100 # The number of tweets to query for at a time, current API limit is 200

  @client = Grackle::Client.new

  def self.client
    @client
  end

  # Attempts to get all tweets for specified twitter screen name
  # Uses Twitter REST API: https://dev.twitter.com/docs/api/1/get/statuses/user_timeline
  # Limited to a maximum of 3200 tweets due to Twitter API
  def self.retrieve_all_tweets_for screen_name, since = nil
    throw :empty_screen_name if screen_name.empty?

    tweets = []
    page = 1

    begin
      while !(res = @client.statuses.user_timeline.json?({:screen_name => screen_name, :count => TWEET_BATCH_SIZE, :page => page, :include_rts => false, :since_id => since ? since : 1})).empty?
        tweets += res
        page += 1
      end
    rescue Grackle::TwitterError => e
      puts "number of tweets returned: #{tweets.count}"
      parse_twitter_error e
    end
    tweets
  end

  # This assumes there are no missing tweets between the earliest and the latest tweets
  def self.retrieve_a_batch_of_tweets_for screen_name
    throw :empty_screen_name if screen_name.empty?

    latest_tweet = Tweet.where(:user_screen_name => screen_name).sort(:created_at.desc).first
    earliest_tweet = Tweet.where(:user_screen_name => screen_name).sort(:created_at.asc).first

    # Get newer tweets if we have a latest one
    since_id = latest_tweet.tweet_id if latest_tweet

    # Twitter API paramaters
    api_params = {
      :screen_name => screen_name,
      :count => TWEET_BATCH_SIZE,
      :include_rts => false
    }
    api_params[:since_id] = since_id if since_id

    tweets_after_latest = @client.statuses.user_timeline.json?(api_params)

    if tweets_after_latest.nil? || tweets_after_latest.empty?
      max_id = earliest_tweet.tweet_id if earliest_tweet

      # Clean up API params for next call
      api_params.delete :since_id
      api_params[:max_id] = max_id

      tweets_before_earliest = @client.statuses.user_timeline.json?(api_params)

      # Twitter includes the tweet specified in max_id, remove it. We are assuming it's always first'
      tweets_before_earliest.shift

      return tweets_before_earliest 
    else
      return tweets_after_latest
    end
  end

  def self.tweet_count_for screen_name
    throw :empty_screen_name if screen_name.empty?

    begin
      result = @client.users.show.json? :screen_name => screen_name
      count = result.statuses_count
    rescue Grackle::TwitterError => e
      parse_twitter_error e
    end

    count
  end

  def self.retrieve_user screen_name
    throw :empty_screen_name if screen_name.empty?

    begin
      result = @client.users.show.json? :screen_name => screen_name
    rescue Grackle::TwitterError => e
      parse_twitter_error e
    end
  end

  private

  def self.parse_twitter_error exception
    throw :screen_name_not_found if exception.status == 404
    throw :twitter_over_capacity if exception.message.match "Unable to decode response: 756"
    throw :rate_limit_reached if exception.status == 400 && exception.message.match("Rate limit exceeded")
    throw exception
  end
end