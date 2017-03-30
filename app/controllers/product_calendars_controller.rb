class ProductCalendarsController < ApplicationController
  before_action :set_product_calendar, only: [:show, :edit, :update, :destroy]

  # GET /product_calendars
  # GET /product_calendars.json
  def index
    @product_calendars = ProductCalendar.all
  end

  # GET /product_calendars/1
  # GET /product_calendars/1.json
  def show
  end

  # GET /product_calendars/new
  def new
    @product_calendar = ProductCalendar.new
  end

  # GET /product_calendars/1/edit
  def edit
  end

  # POST /product_calendars
  # POST /product_calendars.json
  def create
    @product_calendar = ProductCalendar.new(product_calendar_params)

    respond_to do |format|
      if @product_calendar.save
        format.html { redirect_to @product_calendar.product, notice: 'Product calendar was successfully created.' }
        format.json { render :show, status: :created, location: @product_calendar }
      else
        format.html { render :new }
        format.json { render json: @product_calendar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_calendars/1
  # PATCH/PUT /product_calendars/1.json
  def update
    respond_to do |format|
      if @product_calendar.update(product_calendar_params)
        format.html { redirect_to @product_calendar, notice: 'Product calendar was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_calendar }
      else
        format.html { render :edit }
        format.json { render json: @product_calendar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_calendars/1
  # DELETE /product_calendars/1.json
  def destroy
    @product_calendar.destroy
    respond_to do |format|
      format.html { redirect_to product_calendars_url, notice: 'Product calendar was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_calendar
      @product_calendar = ProductCalendar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_calendar_params
      params.require(:product_calendar).permit(:product_id, :price, :date, :status)
    end
end
