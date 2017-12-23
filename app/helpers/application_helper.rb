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

def title(title = nil)
    if title.present?
      content_for :title, title + ' | Snow Schoolers '
    else
      content_for?(:title) ? content_for(:title) : 'Snow Schoolers'
    end
end

  def meta_tag(tag, text)
    content_for :"meta_#{tag}", text
  end

  def yield_meta_tag(tag, default_text='Browse instructors, compare prices, and book lessons at your favorite resort.')
    content_for?(:"meta_#{tag}") ? content_for(:"meta_#{tag}") : default_text
  end


end
