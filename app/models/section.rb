class Section < ApplicationRecord
	has_many :lessons
	belongs_to :sport
	belongs_to :instructor
	belongs_to :shift
	# validate :no_double_booking_instructors, on: :update

	# def name
	# 	return "#{self.age_group} #{self.lesson_type} - #{self.sport.activity_name}"
	# end

	def self.clear_empty_sections
		empty_sections = 0
		Section.all.to_a.each do |section|
			if section.lessons.count == 0
				section.destroy!
				empty_sections += 1
			end
		end
		puts "!!!there were #{empty_sections} empty sections just removed"
	end

	def self.duplicate_ski_section(date,slot)
		Section.create!({
			date: date,
			name: 'Skiing Group Lesson',
			slot: slot,
			sport_id: 1,
			level: 'Beginner',
			capacity: 5
			})
	end

	def self.duplicate_snowboard_section(date,slot)
		Section.create!({
			date: date,
			name: 'Snowboarding Group Lesson',
			slot: slot,
			sport_id: 2,
			level: 'Beginner',
			capacity: 5
			})
	end

	def has_capacity?
		self.capacity > self.student_count
	end

	def instructor_name_for_section
		if self.instructor_id
			return self.instructor.name
		else
			return "Not yet assigned"
		end
	end

	def self.available_section_splits(date, age_type)
		Section.where(date:date,age_group:age_type)
	end

	def parametized_date
		return "#{self.date.strftime("%m")}%2F#{self.date.strftime("%d")}%2F#{self.date.strftime("%Y")}"
	end

	def self.generate_all_sections
		dates = ['2018-12-16','2018-12-17','2018-12-18','2018-12-22','2018-12-23','2018-12-24','2018-12-25','2018-12-26','2018-12-27','2018-12-28','2018-12-29','2018-12-30','2018-12-31',
		'2019-01-01','2019-01-02','2019-01-03','2019-01-04','2019-01-05','2019-01-06','2019-01-07','2019-01-08','2019-01-12','2019-01-13','2019-01-14','2019-01-15','2019-01-19','2019-01-20','2019-01-21','2019-01-22','2019-01-26','2019-01-27','2019-01-28','2019-01-29','2019-02-02','2019-02-03','2019-02-04','2019-02-05','2019-02-09','2019-02-10','2019-02-11','2019-02-12','2019-02-16','2019-02-17','2019-02-18','2019-02-19','2019-02-20','2019-02-21','2019-02-22','2019-02-23','2019-02-24','2019-02-25','2019-02-26','2019-03-02','2019-03-03','2019-03-04','2019-03-05','2019-03-09','2019-03-10','2019-03-11','2019-03-12','2019-03-16','2019-03-17','2019-03-18','2019-03-19','2019-03-23','2019-03-24','2019-03-25','2019-03-26','2019-03-30','2019-03-31','2019-04-01','2019-04-02','2019-04-06','2019-04-07','2019-04-08','2019-04-09','2019-04-13','2019-04-14','2019-04-15']
		dates.each do |date|
			if Section.where(date:date).count == 0
				Section.seed_sections(date)
			end
		end
	end

	def self.seed_sections(date = Date.today)
		#Early-Birds
		Section.create!({
			date: date,
			name: 'Early Bird Skiing',
			slot: GROUP_SLOTS.first,
			sport_id: 1,
			level: 'Beginner',
			capacity: 5
			})
		Section.create!({
			date: date,
			name: 'Early Bird Snowboarding',
			slot: GROUP_SLOTS.first,
			sport_id: 2,
			level: 'Beginner',
			capacity: 5
			})
		#Morning Groups
		Section.create!({
			date: date,
			name: '2hr Morning Skiing',
			slot: GROUP_SLOTS.second,
			sport_id: 1,
			level: 'First-timer',
			capacity: 5
			})
		Section.create!({
			date: date,
			name: '2hr Morning Snowboarding',
			slot: GROUP_SLOTS.second,
			sport_id: 2,
			level: 'First-timer',
			capacity: 5
			})
		#Afternoon Groups
		Section.create!({
			date: date,
			name: '2hr Afternoon Skiing',
			slot: GROUP_SLOTS.third,
			sport_id: 1,
			level: 'Beginner',
			capacity: 5
			})
		Section.create!({
			date: date,
			name: '2hr Afternoon Snowboarding',
			slot: GROUP_SLOTS.third,
			sport_id: 2,
			level: 'Beginner',
			capacity: 5
			})

	end

	def self.fill_sections_with_lessons
		puts "!!!!!Begin method: self.fill_sections_with_lessons"
		sections = Section.all.select{|a| a.date >= Date.today }
		sections.first(50).each do |section|

			num_cycles = 1 #(1..4).to_a.sample
			num_cycles.times do |cycle|
				lt = LessonTime.find_or_create_by({
					date: section.date,
					slot: section.slot
					})
				puts "!!!!!new lesson time created"
				Lesson.create!({
					requester_id: User.first.id,
					guest_email: 'test@example.com',
					instructor_id: Instructor.first.id,
					lesson_time_id: lt.id,
					deposit_status: 'confirmed',
					activity: ['Ski','Snowboard'].sample,
					requested_location: 24,
					phone_number: '555-555-5555',
					gear: [true,false].sample,
					lift_ticket_status: true,
					objectives: 'Test lesson',
					terms_accepted: true,
					how_did_you_hear: 100,
					requester_name: 'John Parent',
					product_id: Product.where(location_id:24,length:"1.00").sample.id,
					section_id: section.id,
					product_name: Product.where(location_id:24,length:"1.00").sample.name,
					class_type: 'group',
					state: "booked"
					})
				Student.create!({
					lesson_id: Lesson.last.id,
					name: "Student #{Lesson.last.id}",
					age_range: 10,
					gender: ['Male','Female'].sample,
					relationship_to_requester: 'Student is my child',
					most_recent_level: "Level 1 - first-time ever, no previous experience.",
					requester_id: User.first.id
					})
				puts "!!!! new lesson created"
			end
		end
	end



	def student_count
		lessons = Lesson.where(section_id:self.id)
		lessons = lessons.to_a.keep_if{|lesson| lesson.completed? || lesson.completable? || lesson.confirmable? || lesson.confirmed? || lesson.booked? || lesson.state.nil? }
		student_count = 0
		lessons.each do |lesson|
			student_count += lesson.students.count
			# lesson.students.each do |student|
			# 	student_count +=1
			# end
		end
		return student_count.to_i
	end

	def remaining_capacity
		self.capacity - self.student_count
	end

	def no_double_booking_instructors
		#TBD - tricky due to nature of AM & PM sections
	    # errors.add(:section, "cannot double book an instructor") unless Instructor.count == 0
	end

end
