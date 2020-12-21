class LessonTime < ActiveRecord::Base
  has_many :lessons
  has_many :tickets
  has_many :calendar_blocks
  has_many :users, through: :lessons

  validates :date, presence: true

  def self.find_morning_slot(date)
    LessonTime.find_by_date_and_slot(date, 'Morning')
  end

  def self.find_afternoon_slot(date)
    LessonTime.find_by_date_and_slot(date, 'Afternoon')
  end

  def self.next_available_slot
    LessonTime.slots_still_open_today
    if slots_still_open_today.empty?
      slot = SLEDDING_SLOTS.first
    else
      return slots_still_open_today.first
    end
  end

  def self.next_available_date
    LessonTime.slots_still_open_today
    if slots_still_open_today.empty?
      date = Date.tomorrow
    else
      date = Date.today
    end
  end

  def self.slots_still_open_today
    array = []
    SLEDDING_SLOTS.each do |slot|
      if Time.now <= LessonTime.find_start_time(slot) #this should be 30min before the end of the current session.
        array << slot
      end
    end
    return array
  end


  def self.find_start_time(slot)
    case slot
    when 'Early-bird (9-10:30am)'
      then '10:00 AM'.to_time
    when 'Morning (11am-12:30pm)'
      then '12:00 PM'.to_time
    when 'Midday (1-2:30pm)'
      then '2:00 PM'.to_time
    when 'Closing(3-4:30pm)'
      then '4:00 PM'.to_time
    when 'Morning (9:30am-1pm)'
      then '12:30 PM'.to_time
    when 'Afternoon (1pm-4:30pm)'
      then '4:00 PM'.to_time
    end
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
    # begin sledding time slots
    when 'Early-bird (9-10:30am)'
      then '9:00 AM'
    when 'Morning (11am-12:30pm)'
      then '11:00 AM'
    when 'Midday (1-2:30pm)'
      then '1:00 PM'
    when 'Closing(3-4:30pm)'
      then '3:00 PM'
    else 'N/A'
    end
  end

end
