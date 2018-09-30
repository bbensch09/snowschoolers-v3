class Resource < ApplicationRecord
  require 'csv'
  has_many :rentals
  has_many :students

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

end
