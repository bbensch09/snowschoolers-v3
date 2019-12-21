class ReportCard < ApplicationRecord
	belongs_to :student
	belongs_to :instructor
	belongs_to :lesson
end
