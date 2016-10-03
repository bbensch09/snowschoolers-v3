class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  after_filter :store_location

def store_location
  # store last url - this is needed for post-login redirect to whatever the user last visited.
  return unless request.get?
  if (request.path != "/users/sign_in" &&
      request.path != "/users/sign_up" &&
      request.path != "/users/password/new" &&
      request.path != "/users/password/edit" &&
      request.path != "/users/confirmation" &&
      request.path != "/users/sign_out" &&
      request.path != "/apply" &&
      request.path != "/thank_you" &&
      !request.xhr? # don't store ajax calls
      )
    session[:previous_url] = request.fullpath
  end
end

def after_sign_in_path_for(resource)
  session[:previous_url] || root_path
end

end


#BEGIN Class for GA Api
require 'rest_client'

class GoogleAnalyticsApi

  def event(category, action, client_id = '555')
    return unless GOOGLE_ANALYTICS_SETTINGS[:tracking_code].present?

    params = {
      v: GOOGLE_ANALYTICS_SETTINGS[:version],
      tid: GOOGLE_ANALYTICS_SETTINGS[:tracking_code],
      cid: client_id,
      t: "event",
      ec: category,
      ea: action
    }

    begin
      RestClient.get(GOOGLE_ANALYTICS_SETTINGS[:endpoint], params: params, timeout: 4, open_timeout: 4)
      puts "-------------GA event recorded."
      return true
    rescue  RestClient::Exception => rex
      puts "-------------GA event NOT recorded."
      return false
    end
  end

end
