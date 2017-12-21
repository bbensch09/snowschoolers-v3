Resque::Mailer.argument_serializer = Resque::Mailer::Serializers::ActiveRecordSerializer

# config/initializers/resque.rb
Resque.logger.level = Logger::DEBUG

# config/initializers/resque.rb
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))