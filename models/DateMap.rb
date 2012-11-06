class DateMap
  include MongoMapper::Document

  key :_id, Hash
    # key '_id.user_screen_name', String
    # key '_id.year', Integer
    # key '_id.month', Integer
    # key '_id.day', Integer
    
  key :value, Hash
    # key 'value.tweet_count', Integer
    # key 'value.tweet_ids', Array

  def year
    self._id['year']
  end
  def month
    self._id['month']
  end
  def day
    self._id['day']
  end
  
  # Searching by Twitter screen name
  ensure_index '_id.screen_name'

  # Ordering by time
  ensure_index '_id.time'

  # Finds DateMaps which ids contain keys and values specified in options
  # TODO: convert to scope
  def self.find_by options = {}
    conditions = {}
    options.each do |key, value|
      conditions[:"_id.#{key}"] = value
    end

    self.where(conditions).sort(:'_id.time'.desc).all
  end

  # Finds the unique occurance of a field based on supplied key and value pairs
  # TODO: convert to scope
  def self.get_distinct_field field, options = {}
    conditions = {}
    options.each do |key, value|
      conditions["_id.#{key}"] = value
    end

    self.collection.distinct("_id.#{field}", conditions)
  end
end