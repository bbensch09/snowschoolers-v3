# Resque tasks

require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task :setup => :environment do
    require 'resque'

    # you probably already have this somewhere
    # Resque.redis = 'localhost:6379'

    # you probably already have this somewhere
    if ENV['HOST_DOMAIN'] == 'localhost:3000'
        Resque.redis = 'localhost:6379'
    elsif ENV['HOST_DOMAIN'] == 'demo.snowschoolers.com'
        Resque.redis = ENV['REDISTOGO_URL']
    elsif ENV['HOST_DOMAIN'] == 'www.snowschoolers.com'
        Resque.redis = ENV['REDISTOGO_URL']
    end
 
    puts "!!! ENV['HOST_DOMAIN'] constant is: #{ENV['HOST_DOMAIN']}"
    puts "!!! ENV['REDISTOGO_URL'] constant is: #{ENV['REDISTOGO_URL']}"

  end

  task :setup_schedule => :setup do
    require 'resque-scheduler'

    # If you want to be able to dynamically change the schedule,
    # uncomment this line.  A dynamic schedule can be updated via the
    # Resque::Scheduler.set_schedule (and remove_schedule) methods.
    # When dynamic is set to true, the scheduler process looks for
    # schedule changes and applies them on the fly.
    # Note: This feature is only available in >=2.0.0.
    # Resque::Scheduler.dynamic = true

    # The schedule doesn't need to be stored in a YAML, it just needs to
    # be a hash.  YAML is usually the easiest.
    Resque.schedule = YAML.load_file(Rails.root+'lib/tasks/resque_schedule.yml')

    # If your schedule already has +queue+ set for each job, you don't
    # need to require your jobs.  This can be an advantage since it's
    # less code that resque-scheduler needs to know about. But in a small
    # project, it's usually easier to just include you job classes here.
    # So, something like this:
    # require 'jobs'
  end

  task :scheduler => :setup_schedule
end


=begin
require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque/scheduler'

    ENV['QUEUE'] = '*'

    Resque.redis = 'localhost:6379' unless Rails.env == 'production'
    Resque.schedule = YAML.load_file(Rails.root+'lib/tasks/resque_schedule.yml')
  end
end

Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

desc "Alias for resque:work (To run workers on Heroku)"
task "jobs:work" => "resque:work"
=end