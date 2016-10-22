class Student < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'

  validates :name, :age_range, :gender, :relationship_to_requester, :most_recent_level, :most_recent_experience, presence: true
end
