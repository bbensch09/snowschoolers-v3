
class WelcomeController < ApplicationController
    skip_before_action :authenticate_user!
  def index
    @lesson = Lesson.new
    @lesson_time = @lesson.lesson_time
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

end
