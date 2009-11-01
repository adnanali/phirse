ROOT_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? ROOT_DIR

require "rubygems"

begin
  require "vendor/dependencies/lib/dependencies"
rescue LoadError
  require "dependencies"
end

require "monk/glue"
require "mongo_mapper"
require "rack-flash"
require "erb"
require "json"

class Main < Monk::Glue
  set :app_file, __FILE__
  use Rack::Session::Cookie

  use Rack::Flash, :sweep => true

  enable :sessions
end

# Connect to mongodb.
MongoMapper.connection = Mongo::Connection.new(settings(:mongodb)[:host], settings(:mongodb)[:port])
MongoMapper.database = settings(:mongodb)[:database]


# Load all application files.
['helpers', 'models', 'routes'].each do |dir| 
  Dir[root_path("app/#{dir}/**/*.rb")].each do |file|
    require file
  end
end

Main.run! if Main.run?
