
# send errors which occur in background jobs to redis and airbrake
require 'resque/failure/multiple'
require 'resque/failure/redis'
# require 'resque/failure/airbrake'

Resque::Failure.backend = Resque::Failure::Multiple

# config/initializers/resque.rb
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))

#start new redis-server on port 6379 whenever running rails server
# $redis = Redis.new(:host => 'localhost', :port => 6379)

if Rails.env == 'production'
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end


# Resque::Mailer.default_queue_name = 'snowschoolers_email_queue'