class Shift < ApplicationRecord
	  belongs_to :instructor

  def self.create_instructor_shifts(date)
  	Instructor.all.to_a.each do |instructor|
  		Shift.create!({
  			start_time: "#{date.to_s} 08:00:00",
  			end_time: "#{date.to_s} 16:00:00",
  			name: ['Snow Rangers - Ski', 'Snow Rangers - Snowboard','Mountain Rangers - Ski', 'Mountain Rangers - Snowboard','Adult Groups - Ski','Adult Groups - Snowboard','Private - Ski','Private - Snowboard'].sample,
  			status: ['TBD', 'Scheduled','Unavailable'].sample,
  			instructor_id: instructor.id
  			})
  	end
  end

  def shift_status_color
  	case self.status
  	when 'TBD'
  		return 'yellow-shift'
  	when 'Scheduled'
  		return 'blue-shift'
  	when 'Unavailable'
  		return 'red-shift'
  	when 'Completed'
  		return 'green-shift'
  	end
  end

end
