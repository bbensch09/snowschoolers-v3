class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  private

  def configure_permitted_parameters
    #devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email])
    #devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :email, bank_attributes: [:bank_name, :bank_account]])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :user_type, :location_id, :password, :password_confirmation, :current_password])
  end

  def update_resource(resource, params)
    if resource.provider == "facebook"
      params.delete("current_password")
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

end
