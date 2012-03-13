require 'mongo_mapper'

if APP_ENV == 'development'
  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = "TUHB-Dev"
elsif APP_ENV == 'test'
  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = "TUHB-Test"
end

MongoMapper.connection.connect
Dir[Dir.pwd + '/models/*.rb'].each {|file| require file } # load Models