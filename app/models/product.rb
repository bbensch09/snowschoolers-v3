class Product < ActiveRecord::Base
  belongs_to :location

  def self.search(search_params)
    matched_locations = Location.where("name ILIKE ?","%#{search_params}%")
    matched_regions = Location.where("region ILIKE ?","%#{search_params}%")
    matched_state = Location.where("state ILIKE ?","%#{search_params}%")
    all_products = Product.all(:joins => :location)
    search_results = []
    matched_locations = matched_locations + matched_regions + matched_state
    matched_locations.each do |location|
      search_results += location.products
    end
    return search_results
  end


end
