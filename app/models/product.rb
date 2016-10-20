class Product < ActiveRecord::Base
  belongs_to :location

  def self.search(search_params)
    search_results = []
    #SEARCH LOCATION BASED ON TEXT
    if search_params[:search_text].length >=1
      matched_locations = Location.where("name ILIKE ?","%#{search_params[:search_text]}%")
      matched_regions = Location.where("region ILIKE ?","%#{search_params[:search_text]}%")
      matched_state = Location.where("state ILIKE ?","%#{search_params[:search_text]}%")
      matched_locations = matched_locations + matched_regions + matched_state
      matched_locations.each do |location|
      search_results += location.products.where(calendar_period:location.calendar_status)
      end
      # puts "FIRST!!!!!!!!the current number of search_results is #{search_results.count}"
      search_results
    else
     search_results = Product.all(:joins => :location)
    end
    search_results.keep_if {|product| product.calendar_period == product.location.calendar_status}
      # puts "SECOND!!!!!!!!the current number of search_results is #{search_results.count}"
    #SEARCH LESSONS BASED ON LENGTH
    if search_params[:length] != [nil,nil,nil,nil,nil]
      search_results = search_results.keep_if {|product| search_params[:length].include?(product.length)}
      # puts "THIRD!!!!!!!!the current number of search_results is #{search_results.count}"
    end
    #FILTER FOR ONLY ACTIVE PARTNERS
    if search_params[:status] == "true"
      search_results = search_results.keep_if { |product| product.location.partner_status == "Active" }
      # puts "FOURTH!!!!!!!!the current number of search_results is #{search_results.count}"
    end
      puts "FIFTH!!!!!!!!! the current number of search_results is #{search_results.count}"
    if search_params[:resort_filter][:location_ids] == [""]
      search_results
    else
      puts "!!!!!!applied a resort filter for the location_ids: #{search_params[:resort_filter][:location_ids]}"
    end
    return search_results
  end


end
