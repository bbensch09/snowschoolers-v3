class Instructor < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :locations
  has_many :lesson_actions
  after_create :send_admin_notification

  validates :username, :first_name, :last_name, :certification, :sport, :intro, presence: true

  def name
    self.first_name + " " + self.last_name
  end

  def send_admin_notification
      @instructor = Instructor.last
      LessonMailer.new_instructor_application_received(@instructor).deliver
      puts "an admin notification has been sent."
  end

end
