
class WelcomeController < ApplicationController
    skip_before_action :authenticate_user!
    # before_action :confirm_admin_permissions, only: [:admin_users]
    before_action :set_user, only: [:admin_edit, :admin_show_user, :admin_update_user]
    include ApplicationHelper

  def index
    @lesson = Lesson.new
    @lesson_time = @lesson.lesson_time
  end

  def admin_users
    @users = User.all.sort {|a,b| a.email <=> b.email}
  end

  def admin_edit
  end

  def admin_update_user1
      puts "--------the user_params are #{user_params}"
        # @user.email = params[:user][:email]
        # @user.user_type = params[:user][:user_type]
        # @user.location_id = params[:user][:location_id]
      if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User was successfully updated.'
      else
        redirect_to admin_edit_user_path(@user), notice: "Unsuccessful. Error: #{@user.errors.full_messages}"
      end
  end

  def admin_update_user
    if user_params[:password].blank?
      Rails.logger.info "entered if statement"
      user_params.delete :password
      user_params.delete :password_confirmation
      Rails.logger.info("Inspect Params #{user_params.inspect}")
    end
    if @user.update(user_params)
      redirect_to @user, notice: 'Did not hit user error. Successfully updated?'
    else
      Rails.logger.info(@user.errors.inspect)
      redirect_to admin_edit_user_path(@user), notice: "Unsuccessful. Error: #{@user.errors.full_messages}"
    end
  end

  def admin_show_user
    redirect_to admin_users_path
  end


  def apply
    @instructor = Instructor.new
    GoogleAnalyticsApi.new.event('instructor-recruitment', 'load-application-page')
    # if current_user.nil?
    #     LessonMailer.track_apply_visits.deliver
    #   else
    #     LessonMailer.track_apply_visits(current_user.email).deliver
    # end
  end

  def notify_admin
    if request.xhr?
      # DEBUGGING JSON PARAMS - CLEAN UP LATER
      # puts "received ajax request"
      # first_name = params[:first_name]
      # last_name = params[:last_name]
      # email = params[:email]
      # puts "email was captured as #{email}."
      if current_user.nil?
        LessonMailer.application_begun(email, first_name, last_name).deliver
      else
        LessonMailer.application_begun(current_user.email).deliver
      end
      render json: {email: email}
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :user_type, :location_id, :password, :password_confirmation, :current_password)
    end

end
