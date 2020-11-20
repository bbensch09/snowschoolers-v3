class Applicant < ApplicationRecord
  	belongs_to :user
	after_create :send_admin_notification
	validates :email, :phone_number, :first_name, :last_name, :intro, presence: true

  def to_param
        [id, name.parameterize].join("-")
  end

  def name
    self.first_name + " " + self.last_name
  end  

  def referral_source
    case self.how_did_you_hear.to_i
    when 1
      return 'From a friend'
    when 2
      return 'Facebook'
    when 3
      return 'Google'
    when 4
      return 'From a Flyer'
    when 5
      return 'Linkedin'
    when 6
      return 'Indeed'
    when 100
      return 'Other'
    end
  end

  def send_admin_notification
      @applicant = Applicant.last
      LessonMailer.new_kingvale_application_received(@applicant).deliver!
      puts "an admin notification has been sent."
  end  

end
