source 'https://rubygems.org'


#delayed_jobs for sending Twilio SMS messages if instructors are unresponsive
gem 'delayed_job_active_record'

#For supporting controller tests from Rails 4
gem 'rails-controller-testing'

#Railties is dependency for various devise and jquery gems in rails 5

gem 'railties'

#stripe for charging credit cards
gem 'stripe'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', '5.0.0.1'
gem 'rails', '5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'

#twilio for SMS notifications
gem 'twilio-ruby'

#AWS SDK's for storing images
# gem 'aws-sdk-v1'
gem 'aws-sdk', '~> 2'

#Using CKeditor as the WYSIWYG editor for potential custom formatting in-line.
gem 'ckeditor'
#paperclip for file upload management
gem 'paperclip'

#suggested by DEVEO article re. GA server-side tracking - http://blog.deveo.com/server-side-google-analytics-event-tracking-with-rails/
gem 'rest-client'

group :development, :test do
  gem  'byebug'
  gem 'better_errors'
  gem 'binding_of_caller'
end

# Use SCSS for stylesheets
gem 'sass-rails'
gem 'bootstrap-sass'
gem 'sprockets-rails', :require => 'sprockets/railtie'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-timepicker-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

gem 'devise'
gem 'formtastic', '~> 3.0'
gem 'formtastic-bootstrap'
gem 'omniauth-facebook'
gem 'cocoon', '>= 1.2.0'

gem 'faker'
gem 'hirb'


# Heroku
group :production do
  gem 'rails_12factor'
end
