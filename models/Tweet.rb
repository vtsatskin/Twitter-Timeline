class Tweet
  include MongoMapper::Document

  STORED_TWEET_DATA_KEYS = [
    :in_reply_to_screen_name,
    :in_reply_to_user_id_str,
    :in_reply_to_status_id_str,
    :created_at,
    :id_str,
    :truncated,
    :source,
    :id,
    :text
  ]

  STORED_TWEET_DATA_KEYS.each do |key_name|
    if key_name == :created_at
      key key_name, Time
    elsif key_name == :id
      key :tweet_id, String
    elsif key_name == :truncated
      key key_name, Boolean
    else
      key key_name, String
    end
  end

  def self.store_tweets_for screen_name
    # TOOD: use since paramater when calling TwitterHelper#retrieve_all_tweets_for
    th = TwitterHelper.new
    tweets = th.retrieve_all_tweets_for(screen_names)
    tweets.map { |tweet| store_tweet_from_grackle tweet }
  end

  private

  def store_tweet_from_grackle grackle_tweet
    data = {}
    STORED_TWEET_DATA_KEYS.each do |key_name|
      data[key_name] = grackle_tweet.send(key_name)
    end
    Tweet.create data
  end
end