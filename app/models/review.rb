class Review < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :reviewer, class_name: 'User', foreign_key: 'reviewer_id'
  belongs_to :lesson
end
