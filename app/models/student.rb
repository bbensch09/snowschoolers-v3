class Student < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  has_many :rentals

  def boot_reserved
    if self.rentals.count == 0
      return "TBD"
    end
    case self.lesson.activity
    when 'Ski'
      then resource_type = 'ski_boot'
    when 'Snowboard'
      then resource_type = 'snowboard_boot'
    end
    boot_rental = self.rentals.to_a.keep_if{|r| r.resource_type == resource_type }
    if boot_rental.first.resource.nil?
      return "TBD"
    end

    return boot_rental.first.resource.gb_identifier
  end

  def ski_or_board_reserved
    if self.rentals.count == 0
      return "TBD"
    end
    case self.lesson.activity
    when 'Ski'
      then resource_type = 'ski'
    when 'Snowboard'
      then resource_type = 'snowboard'
    end
    ski_or_board_rental = self.rentals.to_a.keep_if{|r| r.resource_type == resource_type }
    if ski_or_board_rental.first.resource.nil?
      return "TBD"
    end
    return ski_or_board_rental.first.resource.gb_identifier
  end

  def height_in_inches
  	height = height_feet*12 + height_inches
  end

  def max_ski_length
  	length = (height_in_inches * 2.54).to_i
  end

  def min_ski_length
  	length = (height_in_inches * 2.54*0.85).to_i
  end

  def recommended_beginner_ski_length
    # based on chin height being 86% of body height
    length = (height_in_inches * 2.54*0.86).to_i
  end

  def recommended_intermediate_ski_length
    # based on chin height being 93% of body height
    length = (height_in_inches * 2.54*0.93).to_i
  end

  def recommended_advanced_ski_length
    # based on chin height being 100% of body height
    length = (height_in_inches * 2.54*1.00).to_i
  end

  def max_sb_length
    length = ((height_in_inches * 2.54)*0.9).to_i
  end

  def min_sb_length
    length = ((height_in_inches * 2.54)*0.7).to_i
  end

  def recommended_beginner_snowboard_length
    # based on chin height being 79% of body height
    length = (height_in_inches * 2.54*0.79).to_i
  end

  def recommended_intermediate_snowboard_length
    # based on chin height being 86% of body height
    length = (height_in_inches * 2.54*0.86).to_i
  end

  def recommended_advanced_snowboard_length
    # based on chin height being 93% of body height
    length = (height_in_inches * 2.54*0.93).to_i
  end

  def skier_type_text
    return "" if self.skier_type.nil?
    text_to_split = self.skier_type.split("(")
    return text_to_split.first
  end

  def eligible_shoe_sizes
  	index_actual_size = BOOT_SIZES.index(self.shoe_size)
  	index_min = [0,index_actual_size - 2].max
  	index_max = [29,index_actual_size + 2].min
  	index_eligible = [index_min..index_max].to_a
  	result_array = []
  	index_eligible.each do |index|
  		result_array << BOOT_SIZES[index]
  	end
  	return result_array[0]
  end


  validates :name, :age_range, :gender, :relationship_to_requester, :most_recent_level, presence: true
end
