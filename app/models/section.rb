class Section < ApplicationRecord
	has_many :lessons
	belongs_to :sport
	belongs_to :instructor
	belongs_to :shift

	# def name
	# 	return "#{self.age_group} #{self.lesson_type} - #{self.sport.activity_name}"
	# end

	def instructor_name_for_section
		if self.instructor_id
			return self.instructor.name
		else
			return "Not yet assigned"
		end
	end

	def parametized_date
		return "#{self.date.strftime("%m")}%2F#{self.date.strftime("%d")}%2F#{self.date.strftime("%Y")}"
	end

	def self.seed_sections(date = Date.today)
		Section.create!({
			date: date,
			name: 'Snow Rangers - Ski',
			lesson_type: 'Group Lesson',
			age_group: 'Kids',
			sport_id: 1,
			level: 'First-timer',
			capacity: 5,
			})
		Section.create!({
			date: date,
			name: 'Snow Rangers - Snowboard',
			lesson_type: 'Group Lesson',
			age_group: 'Kids',
			sport_id: 3,
			level: 'First-timer',
			capacity: 5,
			})
		Section.create!({
			date: date,
			name: 'Mountain Rangers - Ski',
			lesson_type: 'Group Lesson',
			age_group: 'Kids',
			sport_id: 1,
			level: 'First-timer',
			capacity: 8,
			})
		Section.create!({
			date: date,
			name: 'Mountain Rangers - Snowboard',
			lesson_type: 'Group Lesson',
			age_group: 'Kids',
			sport_id: 3,
			level: 'First-timer',
			capacity: 8,
			})	
		Section.create!({
			date: date,
			name: 'Adult Groups - AM Ski',
			lesson_type: 'Group Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'First-timer',
			capacity: 10,
			})	
		Section.create!({
			date: date,
			name: 'Adult Groups - AM Snowboard',
			lesson_type: 'Group Lesson',
			age_group: 'Adults',
			sport_id: 3,
			level: 'First-timer',
			capacity: 10,
			})
		Section.create!({
			date: date,
			name: 'Adult Groups - PM Ski',
			lesson_type: 'Group Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'First-timer',
			capacity: 10,
			})	
		Section.create!({
			date: date,
			name: 'Adult Groups - PM Snowboard',
			lesson_type: 'Group Lesson',
			age_group: 'Adults',
			sport_id: 3,
			level: 'First-timer',
			capacity: 10,
			})
		Section.create!({
			date: date,
			name: 'Private - Ski',
			lesson_type: 'Private Lesson',
			age_group: 'Adults',
			sport_id: 1,
			level: 'First-timer',
			capacity: 1,
			})
		Section.create!({
			date: date,
			name: 'Private - Snowboard',
			lesson_type: 'Private Lesson',
			age_group: 'Adults',
			sport_id: 3,
			level: 'First-timer',
			capacity: 1,
			})									

	end

	def student_count
		Lesson.where(section_id:self.id).count
	end

	def remaining_capacity
		self.capacity - self.student_count
	end

end
