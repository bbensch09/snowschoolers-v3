class LessonTime < ActiveRecord::Base
  has_many :lessons
  has_many :calendar_blocks
  has_many :users, through: :lessons

  validates :date, presence: true

  def self.find_morning_slot(date)
    LessonTime.find_by_date_and_slot(date, 'Morning')
  end

  def self.find_afternoon_slot(date)
    LessonTime.find_by_date_and_slot(date, 'Afternoon')
  end

  def start_time
    case slot
    when 'Early Bird (8:45-9:45am)'
      then '8:45 AM'
    when 'Half-day Morning (10am-12:45pm)'
      then '10:00 AM'
    when '2hr Morning 10am-12pm'
      then '10:00 AM'
    when 'Full-day (10am-4pm)'
      then '10:00 AM'
    when 'Half-day Afternoon (1:15-4pm)'
      then '1:00 PM'
    when '2hr Afternoon 1pm-3pm'
      then '1:00 PM'
    else 'N/A'
    end
  end

end
