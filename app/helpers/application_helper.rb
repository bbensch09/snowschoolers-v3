module ApplicationHelper

# lib/google_analytics_api.rb
require 'rest_client'

def resource_name
  :user
end

def resource
  @resource ||= User.new
end

def devise_mapping
  @devise_mapping ||= Devise.mappings[:user]
end

def confirm_admin_permissions
  return if current_user.email == 'brian@snowschoolers.com' || current_user.email == 'bbensch@gmail.com'
  redirect_to root_path, notice: 'You do not have permission to view that page.'
end

end
