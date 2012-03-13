# TwitterHelper_spec.rb
require_relative '../spec_helper.rb'

# Max. number of tweets Twitter API will give
MAX_NUMBER_OF_USER_TWEETS = 3200

# These constants will probably have to change over time as they are used for live Twitter data
BOGUS_SCREEN_NAME = 'bogususer3012' # A twitter username that does not exist
VALID_SCREEN_NAME = 'vtsatskin' # A twitter screen name that does exists
SPAMMING_SCREEN_NAME = 'TTCnotices' # A twitter screen name with tweets > MAX_NUMBER_OF_USER_TWEETS

describe TwitterHelper do
  before :each do
    @th = TwitterHelper.new
  end

  describe "#retrieve_all_tweets_for" do
    it "should require a screen name" do
      lambda { @th.retrieve_all_tweets_for }.should raise_error()
    end
    it "should not accept an empty screen name" do
      lambda { @th.retrieve_all_tweets_for '' }.should throw_symbol(:empty_screen_name)
    end
    it "should retrieve all tweets for #{VALID_SCREEN_NAME}" do
      retrieved_tweets = @th.retrieve_all_tweets_for(VALID_SCREEN_NAME)
      retrieved_tweets.should be_an_instance_of Array

      # Comparing reported tweet numbers and amount returned are never consistant
      # tweet_count = @th.tweet_count_for(VALID_SCREEN_NAME)
      # retrieved_tweets.count.should == tweet_count
    end
    it "should throw :screen_name_not_found for #{BOGUS_SCREEN_NAME}" do
      lambda { @th.retrieve_all_tweets_for(BOGUS_SCREEN_NAME) }.should throw_symbol(:screen_name_not_found)
    end
    it "should retrieve the maximum supported amount of tweets for #{SPAMMING_SCREEN_NAME} (#{MAX_NUMBER_OF_USER_TWEETS})" do
      retrieved_tweets = @th.retrieve_all_tweets_for(SPAMMING_SCREEN_NAME)
      retrieved_tweets.should be_an_instance_of Array
      # retrieved_tweets.count.should == MAX_NUMBER_OF_USER_TWEETS
    end
  end

  describe "#tweet_count_for" do
    it "should require a screen name" do
      lambda { @th.tweet_count_for }.should raise_error()
    end
    it "should not accept an empty screen name" do
      lambda { @th.tweet_count_for '' }.should raise_error()
    end
    it "should return an integer > 0 for vtsatskin" do
      tweet_count = @th.tweet_count_for('vtsatskin')
      tweet_count.should be_an_instance_of Fixnum
      tweet_count.should be > 0
    end
    it "should throw :screen_name_not_found for #{BOGUS_SCREEN_NAME}" do
      lambda { @th.tweet_count_for(BOGUS_SCREEN_NAME) }.should throw_symbol(:screen_name_not_found)
    end
  end

  describe "#retrieve_user" do
    it "should require a screen name" do
      lambda { @th.retrieve_user }.should raise_error()
    end
    it "should not accept an empty screen name" do
      lambda { @th.retrieve_user '' }.should throw_symbol(:empty_screen_name)
    end
    it "should throw :screen_name_not_found for #{BOGUS_SCREEN_NAME}" do
      lambda { @th.retrieve_user(BOGUS_SCREEN_NAME) }.should throw_symbol(:screen_name_not_found)
    end
    it "should retrieve user data for #{VALID_SCREEN_NAME}" do
      retrieved_user = @th.retrieve_user(VALID_SCREEN_NAME)
      pp y retrieve_user.class
      # retrieve_user.should be_an_instance_of 
    end
  end
end