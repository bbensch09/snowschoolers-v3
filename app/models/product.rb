class Product < ActiveRecord::Base
  require 'csv'
  belongs_to :location
  has_many :product_calendars
  has_many :lessons

  def current_price
    matched_prices = ProductCalendar.where(product_id:self.id,date:Date.today)
    if matched_prices.count > 0
      return matched_prices.first.price
    else
      return self.price
    end
  end

  def age_group
    case self.age_type 
      when "Child"
        return "Kids"
      when "Adult"
        return "Adults"
      end
  end

  def self.import(file)
    CSV.foreach(file.path, headers:true) do |row|
      product = Product.find_or_create_by(id: row['id'])
      product.update_attributes(row.to_hash)
      puts "new product created with name: #{Product.last.name}"
    end
  end

  def self.to_csv(options = {})
    desired_columns = %w{
      name  location_id details calendar_period price length  slot  start_time  product_type  age_type  url is_multi_day  is_lesson is_private_lesson is_group_lesson is_lift_ticket  is_rental is_lift_rental_package  is_lift_lesson_package
    }
    CSV.generate(headers: true) do |csv|
      csv << desired_columns
      all.each do |product|
        csv << product.attributes.values_at(*desired_columns)
      end
    end
  end


  def self.search(search_params)
    search_results = []
    #SEARCH LOCATION BASED ON TEXT
    if search_params[:search_text].length >=1
      # puts "!!!!!!!!!!!!entered text-based location search"
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
     search_results = Product.all #(:joins => :location)
    end
    search_results.to_a.keep_if {|product| product.location && product.calendar_period == product.location.calendar_status}
      # puts "SECOND!!!!!!!!the current number of search_results is #{search_results.count}"
    #SEARCH LESSONS BASED ON LENGTH
    unless search_params[:length].nil?
      search_results = search_results.to_a.keep_if {|product| search_params[:length].include?(product.length)}
      # puts "THIRD!!!!!!!!the current number of search_results is #{search_results.count}"
    end
    #FILTER FOR ONLY ACTIVE PARTNERS
    if search_params[:status] == "true"
      search_results = search_results.to_a.keep_if { |product| product.location && product.location.partner_status == "Active" }
      # puts "FOURTH!!!!!!!!the current number of search_results is #{search_results.count}"
    end
      # puts "FIFTH!!!!!!!!! the current number of search_results is #{search_results.count}"
    if search_params[:resort_filter].nil? || search_params[:resort_filter][:location_ids] == [""]
      search_results
    else
      location_ids = search_params[:resort_filter][:location_ids]
      search_results = search_results.to_a.keep_if {|product| location_ids.include?(product.location_id.to_s)}
      # puts "SIXTH!!!!!!!!! the current number of search_results is #{search_results.count}"
    end
    if search_params[:slot] && search_params[:slot] != "Any Slot"
      search_results = search_results.to_a.keep_if {|product| product.slot == search_params[:slot]}
      # puts "SEVENTH!!!!!!!!! the current number of search_results is #{search_results.count}"
    end
    if search_params[:pass_type] && search_params[:pass_type] != "All Passes"
      search_results = search_results.to_a.keep_if {|product| product.age_type == search_params[:pass_type]}
      puts "pass type filter: #{search_params[:pass_type]}"
      puts "EIGHTH!!!!!!!!! the current number of search_results is #{search_results.count}"
    end
    return search_results
  end


end
