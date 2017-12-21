#config/initializers/redis.rb
require 'redis'

# REDIS_CONFIG = YAML.load( File.open( Rails.root.join("config/redis.yml") ) ).symbolize_keys
# dflt = REDIS_CONFIG[:default].symbolize_keys
# cnfg = dflt.merge(REDIS_CONFIG[Rails.env.to_sym].symbolize_keys) if REDIS_CONFIG[Rails.env.to_sym]

# $redis = Redis.new(cnfg)
# Redis::Objects.redis = $redis
#$redis_ns = Redis::Namespace.new(cnfg[:namespace], :redis => $redis) if cnfg[:namespace]

# To clear out the db before each test
# $redis.flushdb if Rails.env = "test"


# send errors which occur in background jobs to redis and airbrake
require 'resque/failure/multiple'
require 'resque/failure/redis'
# require 'resque/failure/airbrake'

Resque::Failure.backend = Resque::Failure::Multiple

# config/initializers/resque.rb
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))


#use redistgo for production heroku server
if Rails.env.production? || ENV['HOST_DOMAIN'] == 'demo.snowschoolers.com'
  puts "!!! production: #{ENV['REDISTOGO_URL']}"
  uri = URI.parse(ENV["REDISTOGO_URL"])
#otherwise start new redis-server on port 6379 whenever running locally
else
  puts "!!! not running on production"
  uri = URI.parse("redis://localhost:6379")
end

Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)