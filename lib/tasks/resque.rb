#config/initializers/redis.rb
require 'redis'
require 'redis/objects'

# REDIS_CONFIG = YAML.load( File.open( Rails.root.join("config/redis.yml") ) ).symbolize_keys
# dflt = REDIS_CONFIG[:default].symbolize_keys
# cnfg = dflt.merge(REDIS_CONFIG[Rails.env.to_sym].symbolize_keys) if REDIS_CONFIG[Rails.env.to_sym]

# $redis = Redis.new(cnfg)
# Redis::Objects.redis = $redis
#$redis_ns = Redis::Namespace.new(cnfg[:namespace], :redis => $redis) if cnfg[:namespace]

# To clear out the db before each test
# $redis.flushdb if Rails.env = "test"

# Resque tasks
require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'

    ENV['QUEUE'] = '*'

    Resque.redis = ENV['REDIS_URL']
    Resque.schedule = YAML.load_file(File.join(Rails.root, 'config/resque_scheduler.yml'))
  end
end

Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"

ENV['test_resque_env'] = 'testing123'