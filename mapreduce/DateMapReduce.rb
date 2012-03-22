class DateMapReduce
  def self.run screen_name = nil
    map = <<JS
      function(){
        key = {
          screen_name: this.user_screen_name,
          year: this.created_at.getFullYear(),
          month: this.created_at.getMonth(),
          day: this.created_at.getDay(),
        }
        emit(key, {tweet_count: 1, tweet_ids: [this.tweet_id]});
      }
JS

    reduce = <<JS
      function(key, values) {
        var tweet_count = 0;
        var tweet_ids = [];
        
        values.forEach(function(value){
          tweet_count += value.tweet_count;
          tweet_ids = tweet_ids.concat(value.tweet_ids);
        });
        
        return {tweet_count: tweet_count, tweet_ids: tweet_ids};
      }
JS
    # Tweet.collection.map_reduce(map, reduce, :query => {}, :out => { :replace => 'date_maps'})
    Tweet.collection.map_reduce(map, reduce, :query => { :user_screen_name => screen_name ? screen_name : { '$exists' => true} }, :out => { :merge => 'date_maps' })
  end  
end