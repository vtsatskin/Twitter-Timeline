class UserMap
  include MongoMapper::Document
  
  key :value, Integer
  
  ensure_index :_id
end