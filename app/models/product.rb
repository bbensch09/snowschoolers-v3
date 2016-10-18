class Product < ActiveRecord::Base
  belongs_to :location

  def self.search(search_params)
    where("name ILIKE ?","%#{search_params}%")
  end


end
