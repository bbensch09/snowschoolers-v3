class Resource < ApplicationRecord
  require 'csv'
  has_many :rentals
  has_many :students

  def availability(rental)
    this_rental = Rental.where(rental_date:rental.rental_date,resource_id:self.id,id:rental.id)
    other_rentals = Rental.where(rental_date:rental.rental_date,resource_id:self.id)
    if this_rental.count > 0
      return 'Already Reserved'
    elsif other_rentals.count > 0
      return  'Not Available'
    else
      return 'Available'
    end
  end

  def self.search(rental)
    resource_type = rental.resource_type
    case resource_type
      when 'ski'
        resources = Resource.where(resource_type:resource_type,board_size:rental.min_size..rental.max_size)
      when 'snowboard'
        resources = Resource.where(resource_type:resource_type,board_size:rental.min_size..rental.max_size)
      when 'ski_boot'
        resources = Resource.where(resource_type:resource_type)
        resources = resources.to_a.keep_if{ |resource| rental.shoe_sizes.include?(resource.boot_size) }
      when 'snowboard_boot'
        resources = Resource.where(resource_type:resource_type)
        resources = resources.to_a.keep_if{ |resource| rental.shoe_sizes.include?(resource.boot_size) }
      else
    end
    # resources = resources.to_a.keep_if {|resource| resource.availability(rental) != 'Reserved'}
    return resources
  end

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
      resource = Resource.find_or_create_by(id: row['id'])
      resource.update_attributes(row.to_hash)
      puts "new resource created."
      # puts "new resource created with ss_unique_identifier: #{Resource.last.ss_unique_identifier}"
    end
  end

  def self.to_csv(options = {})
    desired_columns = %w{
   		resource_type gb_identifier manufacturer board_model binding_model is_boot boot_age boot_size_raw boot_size board_size status ss_unique_identifier non_unique_identifier walk_in_only
    }
    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      all.each do |resource|
        csv << resource.attributes.values_at(*desired_columns)
      end
    end
  end

  def resource_type_text
    case resource_type
    when 'ski'
      return 'Skis'
    when 'snowboard'
      return 'Snowboard'
    when 'ski_boot'
      return 'Ski Boots'
    when 'snowboard_boot'
      return 'Snowboard Boots'
    else
    end
  end

end
