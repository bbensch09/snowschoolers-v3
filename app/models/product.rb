class Product < ActiveRecord::Base
  belongs_to :location

  def self.search(search_params)
    search_results = []
    if search_params[:search_text].length >=1
    matched_locations = Location.where("name ILIKE ?","%#{search_params[:search_text]}%")
    matched_regions = Location.where("region ILIKE ?","%#{search_params[:search_text]}%")
    matched_state = Location.where("state ILIKE ?","%#{search_params[:search_text]}%")
    matched_locations = matched_locations + matched_regions + matched_state
    matched_locations.each do |location|
      search_results += location.products.where(calendar_period:location.calendar_status)
      end
    else
     search_results = Product.all(:joins => :location)
    end

    if search_params[:length] != [nil,nil,nil,nil]
      search_results = search_results.keep_if {|product| search_params[:length].include?(product.length)}
    end
    return search_results
  end


end
