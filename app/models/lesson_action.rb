class LessonAction < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :instructor
end
