class SelfiesController < ApplicationController
  before_action :set_selfy, only: [:show, :edit, :update, :destroy]

  # GET /selfies
  # GET /selfies.json
  def index
    @selfies = Selfie.all
  end

  # GET /selfies/1
  # GET /selfies/1.json
  def show
  end

  # GET /selfies/new
  def new
    @selfy = Selfie.new
  end

  # GET /selfies/1/edit
  def edit
  end

  # POST /selfies
  # POST /selfies.json
  def create
    @selfy = Selfie.new(selfy_params)

    respond_to do |format|
      if @selfy.save
        format.html { redirect_to @selfy.contestant, notice: 'Selfie was successfully created.' }
        format.json { render :show, status: :created, location: @selfy }
      else
        format.html { render :new }
        format.json { render json: @selfy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /selfies/1
  # PATCH/PUT /selfies/1.json
  def update
    respond_to do |format|
      if @selfy.update(selfy_params)
        format.html { redirect_to @selfy.contestant, notice: 'Selfie was successfully updated.' }
        format.json { render :show, status: :ok, location: @selfy }
      else
        format.html { render :edit }
        format.json { render json: @selfy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /selfies/1
  # DELETE /selfies/1.json
  def destroy
    @selfy.destroy
    respond_to do |format|
      format.html { redirect_to selfies_url, notice: 'Selfie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_selfy
      @selfy = Selfie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def selfy_params
      params.require(:selfie).permit(:link, :location_id, :contestant_id, :date, :social_network)
    end
end
