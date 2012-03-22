class TweetDay
  include MongoMapper::Document

  key :value, Integer

  def year
    self.id['year']
  end
  def month
    self.id['month']
  end
  def day
    self.id['day']
  end
  ensure_index :_id
end