class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_user
  after_action :store_location

#TO REFACTOR LATER - CUSTOMIZED METHODS TO INTERCEPT DEFAULT ERROR HANDLING FOR 404s and 500s
  rescue_from ActiveRecord::RecordNotFound, :with => :houston_we_have_a_problem
  unless Rails.application.config.consider_all_requests_local
    # rescue_from ActionController::RoutingError, :with => :houston_we_have_500_routing_problems
    # rescue_from ActionController::UnknownController, :with => :houston_we_have_500_routing_problems
  end
  # rescue_from Exception, :with => :houston_we_have_an_exceptional_problem

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

def set_user
  if current_user
    cookies[:userId] = current_user.id
    else
      cookies[:userId] = 'guest'
    end
end

def houston_we_have_a_problem
  render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  HOUSTON_WE_HAVE_A_404_PROBLEM
end

def houston_we_have_500_routing_problems
  render :file => "#{Rails.root}/public/500.html", :status => 500, :layout => false
  HOUSTON_WE_HAVE_500_ROUTING_PROBLEMS
end

def houston_we_have_an_exceptional_problem
  render :file => "#{Rails.root}/public/422.html", :status => 422, :layout => false
  HOUSTON_WE_HAVE_EXCEPTIONAL_PROBLEMS
end




end
