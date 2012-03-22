class UserMapReduce
  def self.run
    map = <<JS
      function(){
        emit(this.user_screen_name, 1);
      }
JS

    reduce = <<JS
      function(key, values) {
        var sum = 0;
        values.forEach(function(value){
          sum += value;
        });
        return sum;
      }
JS
    if Tweet.collection.count > 0
      Tweet.collection.map_reduce(map, reduce, :query => {}, :out => { :merge => 'user_maps'})
    end
  end  
end