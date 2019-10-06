def availabile_instructors
	# find instructors eligible to teach with matching sport, location
	instructors = Instructors.where(location_ids.include?(self.location_id),sport_ids.include(self.sport_id),status:'active')
	# for each instructor
	instructors.each do |i|
		# check if instructor has calendar availability, and does not have any other bookings with overlapping times
		available_slots = CalendarInstructorLocationSlots.where(date:self.date,location_id:self.location_id,avialbility:true)
		matching_slots = []
		available_slots.each do |a|
			if self.product.start_time >= a.start_time && and self.product.start_time <= a.end_time
				matching_slots << a
				return true
			end
		end

		#check to see if instructor is already booked already on that date
		# request for lesson 10-11am custom 1hr
		# previous lesson l: 10-1245pm
		other_booked_lessons = Lessons.where(self.is_booked?,instructor_id:i.id,date:self.date)
		other_booked_lessons.each do |booked_lesson|
			#for any new lesson request, it must either start after other one ends, or and before other one starts
			return true self.start_time >= booked_lesson.end_time || self.end_time <= booked_lesson.start_time
			else return false
		end

	end
	CalendarDate.where(location_id:self.location_id,date:self.date)
end


products
- name (Early Bird, Half Day AM)
- sport (Skiing, Snowboarding)
- location_id
- start_time
- end_time
- ability_level (first-timer, beginner, intermediate, advanced)
- price
- calendar_period (base, prime, holiday)

locations
- name
- mountain specs
- calendar_id

calendar_days
- location_id
- date
- calendar_period
- prime_day:boolean


calendar_instructor_location_slots
- instructor_id
- location_id 
- date
- start_time (default to full-day, options for AM, PM, hourly)
- end_time
- availability:boolean

lessons
- instructor_id
- guest_id
- student_ids
- product_id
- location_ids
- review_id
- transactions
- booking_stage (new, form_begun, ready_to_book, booked, instructor_confirmed, active, awaiting_review, completed, canceled, pending_reschedule)

users
- first_name
- last_name
- email

instuctors
- user_id
- sport_ids
- certification_level
- wage_rate
- phone_number
- bio
- application_fields

guests 
- user_id
- guest_stage
- payment_token
- dim_guest_rating

students 
- guest_id
- first_name
- last_name
- age
- height_inches
- weight_lbs
- shoe_size
- ability_level





