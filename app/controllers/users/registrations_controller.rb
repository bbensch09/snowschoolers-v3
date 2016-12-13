class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  def after_confirmation_path_for(resource_name, resource)
    root_path
  end

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      sign_in(resource) # <= THIS LINE ADDED
      flash[:notice] = 'Thank you, your email address has been confirmed. You are now signed in.'
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :user_type, :location_id, :password, :password_confirmation, :current_password])
  end

  def update_resource(resource, params)
    if resource.provider == "facebook"
      params.delete("current_password")
      resource.update_without_password(params)
    else
      resource.update_without_password(params)
      # resource.update_with_password(params)
    end
  end


end
