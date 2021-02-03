# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_snow_schoolers_session'

ActionController::Base.session = {
  :key          => '_snow_schoolers_session',
  :secret       => 'ss_109_2021_5567'
  :expire_after => 30.days
}
