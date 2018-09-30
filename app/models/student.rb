class Student < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'

  def height_in_inches
  	height = height_feet*12 + height_inches
  end

  def max_ski_length
  	length = (height_in_inches * 2.54).to_i
  end

  def min_ski_length
  	length = (height_in_inches * 2.54*0.85).to_i
  end

  def max_sb_length
  	length = ((height_in_inches * 2.54)*0.9).to_i
  end

  def min_sb_length
  	length = ((height_in_inches * 2.54)*0.7).to_i
  end

  def eligible_shoe_sizes
  	index_actual_size = BOOT_SIZES.index(self.shoe_size)
  	index_min = [0,index_actual_size - 2].max
  	index_max = [29,index_actual_size+2].min
  	index_eligible = [index_min..index_max].to_a
  	result_array = []
  	index_eligible.each do |index|
  		result_array << BOOT_SIZES[index]
  	end
  	return result_array[0]
  end


  validates :name, :age_range, :gender, :relationship_to_requester, :most_recent_level, presence: true
end
