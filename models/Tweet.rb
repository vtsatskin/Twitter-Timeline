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
    :text
  ]
  STORED_TWEET_USER_DATA_KEYS = [
    :id_str,
    :screen_name,
    :name
  ]

  STORED_TWEET_DATA_KEYS.each do |key_name|
    if key_name == :created_at
      key key_name, Time
    elsif key_name == :id_str
      key :tweet_id, String, :unique => true
    elsif key_name == :truncated
      key key_name, Boolean
    else
      key key_name, String
    end
  end
  STORED_TWEET_USER_DATA_KEYS.each { |key_name| key "user_#{key_name}".to_sym, String }

  ensure_index [[:user_screen_name, 1], [:created_at, -1]]

  def self.store_tweets_for screen_name
    # TOOD: use since paramater when calling TwitterHelper#retrieve_all_tweets_for
    tweets = TwitterHelper.retrieve_all_tweets_for(screen_names)
    tweets.map { |tweet| self.store_tweet_from_grackle tweet }
  end

  # Stores tweets in batches of 200 until done
  def self.store_tweets_in_batches_for screen_name
    until (tweet_batch = TwitterHelper.retrieve_a_batch_of_tweets_for(screen_name)).empty?
      tweet_batch.each { |tweet| self.store_tweet_from_grackle tweet }
    end
  end

  def self.store_tweet_from_grackle grackle_tweet
    data = {}
    STORED_TWEET_DATA_KEYS.each do |key_name|
      if key_name == :id_str
        data[:tweet_id] = grackle_tweet.id_str
      else
        data[key_name] = grackle_tweet.send(key_name)
      end
    end
    STORED_TWEET_USER_DATA_KEYS.each { |key_name| data["user_#{key_name}".to_sym] = grackle_tweet.user.send(key_name) }
    Tweet.create data
  end
end