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
    it "should do something"
  end

  describe "::store_tweets_for" do
    it "should " do
      
    end
  end
end