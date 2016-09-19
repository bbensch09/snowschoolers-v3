class Instructor < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :locations
  after_create :send_admin_notification


  def name
    self.first_name + " " + self.last_name
  end

  def send_admin_notification
      @user = Instructor.last.user
      LessonMailer.new_instructor_application_received(@user).deliver
      puts "an admin notification has been sent."
  end

end
