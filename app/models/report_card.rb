class ReportCard < ApplicationRecord has_and_belongs_to_many :skills_practiced
  	has_and_belongs_to_many :skills_recommended
	belongs_to :student
	belongs_to :instructor
	belongs_to :lesson
end
