class CalendarBlock < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :lesson_time

  validates :lesson_time, presence: true
end
