class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  # before_action :confirm_admin_permissions
  skip_before_action :authenticate_user!, except: [:import, :delete_all, :index, :create, :destroy, :edit]



  def import
   Product.import(params[:file])
   redirect_to products_path, notice: "New products data successfully imported."
  end

  def delete_all
    Product.delete_all
    redirect_to products_path, notice: "All products have been deleted."
  end

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
    respond_to do |format|
          format.html
          format.csv { send_data @products.to_csv, filename: "products-PROD-#{Date.today}.csv" }
          format.xls
    end

  end

  def search_results
    if params[:search]
      @search_params = {search_text: params[:search], length: [params[:search_length_1],params[:search_length_2],params[:search_length_3],params[:search_length_6],params[:search_length_7]],status: params[:search_status],slot: params[:search_slot],resort_filter: params[:resort_filter]}
      puts "!!!!! the search_params are: #{@search_params}"
      @products = Product.search(@search_params)
    else
      @products = Product.all.order("price ASC")
    end
    case params[:sort_tag]
      when "Price Low to High"
        @products.sort! {|a,b| a.price <=> b.price}
      when "Price High to Low"
        @products.sort! {|a,b| b.price <=> a.price}
      when "South Tahoe Only"
        @products.keep_if {|product| product.location.region == "South Lake Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "North Tahoe Only"
        @products.keep_if {|product| product.location.region == "North Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "Resort A-Z"
        @products.sort! {|a,b| a.location.name <=> b.location.name}
      else
        @products.sort! {|a,b| a.price <=> b.price}
    end
  end

  def pass_search_results
    if params[:search]
      @search_params = {search_text: params[:search],status: params[:search_status],pass_type: params[:search_pass_type],resort_filter: params[:resort_filter],sort_tag: params[:sort_tag]}
      puts "!!!!! the search_params are: #{@search_params}"
      @products = Product.search(@search_params)
      @products = @products.to_a.keep_if {|product| product.product_type == "season_pass"}
      @products = @products.sort! {|a,b| a.price <=> b.price }
    else
      @products = Product.all.to_a.keep_if {|product| product.product_type == "season_pass"}
      @products = @products.sort! {|a,b| a.price <=> b.price }
    end
    case params[:sort_tag]
      when "Price Low to High"
        @products.sort {|a,b| a.price <=> b.price}
      when "Price High to Low"
        @products.sort {|a,b| b.price <=> a.price}
      when "South Tahoe Only"
        @products.keep_if {|product| product.location.region == "South Lake Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "North Tahoe Only"
        @products.keep_if {|product| product.location.region == "North Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "Resort A-Z"
        @products.sort {|a,b| a.location.name <=> b.location.name}
      else
        @products.sort {|a,b| a.price <=> b.price}
    end
  end

  def learn_to_ski_packages_search_results
    if params[:resort_filter]
      @search_params = {search_text: params[:search],status: params[:search_status],pass_type: params[:search_pass_type],resort_filter: params[:resort_filter],sort_tag: params[:sort_tag]}
      puts "!!!!! the search_params are: #{@search_params}"
      @products = Product.search(@search_params)
      @products = @products.to_a.keep_if {|product| product.product_type == "learn_to_ski"}
    else
      puts "!!!!no search params detected"
      @products = Product.all.order("price ASC")
      @products = @products.to_a.keep_if {|product| product.product_type == "learn_to_ski"}
    end
    case params[:sort_tag]
      when "Price Low to High"
        @products.sort! {|a,b| a.price <=> b.price}
      when "Price High to Low"
        @products.sort! {|a,b| b.price <=> a.price}
      when "South Tahoe Only"
        @products.keep_if {|product| product.location.region == "South Lake Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "North Tahoe Only"
        @products.keep_if {|product| product.location.region == "North Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "Resorts A-Z"
        @products.sort! {|a,b| a.location.name <=> b.location.name}
      else
        @products.sort! {|a,b| a.price <=> b.price}
    end
  end

  def private_lessons_search_results
    if params[:resort_filter]
      @search_params = {search_text: params[:search],status: params[:search_status],pass_type: params[:search_pass_type],resort_filter: params[:resort_filter],sort_tag: params[:sort_tag]}
      puts "!!!!! the search_params are: #{@search_params}"
      @products = Product.search(@search_params)
      @products = @products.to_a.keep_if {|product| product.product_type == "private_lesson"}
    else
      puts "!!!!no search params detected"
      @products = Product.all.order("price ASC")
      @products = @products.to_a.keep_if {|product| product.product_type == "private_lesson"}
    end
    case params[:sort_tag]
      when "Price Low to High"
        @products.sort! {|a,b| a.price <=> b.price}
      when "South Tahoe Only"
        @products.keep_if {|product| product.location.region == "South Lake Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "North Tahoe Only"
        @products.keep_if {|product| product.location.region == "North Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "Price High to Low"
        @products.sort! {|a,b| b.price <=> a.price}
      when "Resorts A-Z"
        @products.sort! {|a,b| a.location.name <=> b.location.name}
      else
        @products.sort! {|a,b| a.price <=> b.price}
    end
  end

  def lift_tickets_search_results
    if params[:resort_filter]
      @search_params = {search_text: params[:search],status: params[:search_status],pass_type: params[:search_pass_type],resort_filter: params[:resort_filter],sort_tag: params[:sort_tag]}
      puts "!!!!! the search_params are: #{@search_params}"
      @products = Product.search(@search_params)
      @products = @products.to_a.keep_if {|product| product.product_type == "lift_ticket"}
    else
      puts "!!!!no search params detected"
      @products = Product.all.order("price ASC")
      @products = @products.to_a.keep_if {|product| product.product_type == "lift_ticket"}
    end
    case params[:sort_tag]
      when "Price Low to High"
        @products.sort! {|a,b| a.price <=> b.price}
      when "South Tahoe Only"
        @products.keep_if {|product| product.location.region == "South Lake Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "North Tahoe Only"
        @products.keep_if {|product| product.location.region == "North Tahoe"}
        @products.sort! {|a,b| a.price <=> b.price}
      when "Price High to Low"
        @products.sort! {|a,b| b.price <=> a.price}
      when "Resorts A-Z"
        @products.sort! {|a,b| a.location.name <=> b.location.name}
      else
        @products.sort! {|a,b| a.price <=> b.price}
    end
  end
  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :price, :location_id, :calendar_period, :search, :length, :slot, :start_time, :search_length, :search_status, :search_slot, :search_cert, :search_sport, :search_location, :sort_tag, :search_pass_type, :product_type, :is_lesson, :is_private_lesson, :is_group_lesson, :is_lift_ticket, :is_rental, :is_lift_rental_package, :is_lift_lesson_package, :is_lift_less_rental_package, :is_multi_day, :age_type, :details, :url)
    end

    def confirm_admin_permissions
      return if current_user.email == 'brian@snowschoolers.com' || current_user.email == 'bbensch@gmail.com' #|| current_user.user_type == "Partner"
      redirect_to root_path, notice: 'You do not have permission to view that page.'
    end

end
