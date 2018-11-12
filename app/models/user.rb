require 'csv'

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable, :confirmable,
         :omniauthable, :omniauth_providers => [:facebook]

  validates :email, uniqueness: true
  validates :password, length: { in: 5..128 }, on: :create
  validates :password, length: { in: 5..128 }, on: :update, allow_blank: true

  has_many :lessons, foreign_key: 'requester_id'
  has_many :reviews
  has_many :transactions
  has_many :students, class_name: 'Student', foreign_key: 'requester_id'
  has_one :instructor
  has_one :applicant
  has_one :contestant
  belongs_to :location
  has_many :lesson_times, through: :lessons
  after_create :send_admin_notification

  def self.to_csv(options = {})
    desired_columns = %w{id email name user_type resort_affiliation created_at}
    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      all.each do |user|
        csv << user.attributes.values_at(*desired_columns)
      end
    end
  end

  def username_for_admin
    email_text = self.email[/[^@]+/]
    email_for_sort = "   #{email_text}_#{rand(100)}"
  end

  def send_admin_notification
      @user = User.last
      LessonMailer.new_user_signed_up(@user).deliver!
      puts "an admin notification has been sent."
  end

  def self.confirm_all_users
    User.all.each do |user|
      user.confirm
    end
  end

  def self.instructors
    self.where('instructor = true')
  end

  def display_name
    if self.name.nil?
      "Anonymous User"  
    elsif
      self.email == "brian@snowschoolers.com"
      sample_names = ['Ken','Bryan','Don','Carl','Bob','Aaron','Ashley','Kevin','Robert','Tessa','Gary','Dee','Ryan','Sean']
      return sample_names[rand(14)]
    else
      return name
    end
  end

  def lesson_times
    Lesson.find_lesson_times_by_requester(self)
  end

  def active_instructor?
    return true if self.instructor && self.instructor.status == "Active"
  end

  def instructor_candidate?
    return true if self.instructor && (self.instructor.status == "new applicant" || self.instructor.status == "Revoked")
  end

  # Facebook OAuth

  # def self.find_email_for_facebook_oauth(auth)
  #       where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  #         return auth.info.email.
  #       end
  # end

  def self.find_for_facebook_oauth(auth)
    # where(auth.slice(:provider, :uid)).first_or_create do |user|
    if self.where(email: auth.info.email).exists?
      user = self.where(email: auth.info.email).first
      user.skip_confirmation!
      return user
      # user.provider = auth.provider
      # user.uid = auth.uid
      # user.save!
    else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.name = auth.info.name
        user.instructor = false
        user.image = auth.info.image
        user.skip_confirmation!
        user.save!
      end
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  # Devise overrides

  def password_required?
    super || provider.blank?
  end

  def update_with_password(params, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if valid_password?(current_password)
      update_columns(params, *options)
    else
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.messages.delete(:password) unless params[:password]
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    clean_up_passwords
    result
  end
end
