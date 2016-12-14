
class WelcomeController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :confirm_admin_permissions, only: [:admin_users,:admin_edit, :admin_destroy]
    before_action :set_user, only: [:admin_edit, :admin_show_user, :admin_update_user, :admin_destroy]
    include ApplicationHelper

  def new_hire_packet
    file = "public/Homewood-Hire-Packet-2016-2017.pdf"
    if File.exists?(file)
      send_file file, :type=>"application/pdf", :x_sendfile=>true
    else
      flash[:notice] = 'File not found'
      redirect_to :index
    end
  end

  def index
    # @lesson = Lesson.new
    # @lesson_time = @lesson.lesson_time
  end

  def about_us
  end

  def launch_announcement
  end

  def admin_users
    @users = User.all.sort {|a,b| a.email <=> b.email}
    @exported_users = User.all
    respond_to do |format|
          format.html
          format.csv { send_data @exported_users.to_csv, filename: "all_users-#{Date.today}.csv" }
          format.xls
    end
  end

  def admin_edit
  end

  def admin_update_user
    if @user.update(user_params)
        redirect_to admin_users_path, notice: 'User was successfully updated. If email was changed, it will need to be confirmed.'
    else
      Rails.logger.info(@user.errors.inspect)
      redirect_to admin_edit_user_path(@user), notice: "Unsuccessful. Error: #{@user.errors.full_messages}"
    end
  end

  def admin_show_user
    redirect_to admin_users_path
  end

   def admin_destroy
    @user.destroy
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
      first_name = params[:first_name]
      last_name = params[:last_name]
      email = params[:email]
      if current_user.nil?
        LessonMailer.application_begun(email, first_name, last_name).deliver
      else
        LessonMailer.application_begun(current_user.email).deliver
      end
      render json: {notice: "Email has been validated."}
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
