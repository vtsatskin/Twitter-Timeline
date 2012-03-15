# tweet_spec.rb
require_relative '../spec_helper.rb'

describe Tweet do
  it "should be able to store arbitrary data" do
    t = Tweet.create(:arbitrary_data => "hello")
    Tweet.last['arbitrary_data'].should == t['arbitrary_data']
  end

  it "should have a clean database every run" do
    Tweet.count.should == 0
  end

  describe "::store_tweets_for" do
    it "should do something" do
      
    end
  end

  describe "::store_tweet_from_grackle" do
    let(:grackle) { Grackle::Client.new }
    it "should store a valid tweet from grackle" do
      tweet = grackle.statuses.show.json?({:id => 1110})
      stored_tweet = Tweet.store_tweet_from_grackle(tweet)
      Tweet.last.new_record?.should == false
      pp y Tweet.last
    end
    it "should not store an invalid tweet from grackle" do
      
    end
  end
end