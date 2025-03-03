class Admin::AreasController < ApplicationController
  def index
  end

  def new
    @area = Area.new
  end

  def create
    @area = Area.new(area_params)
    if @area.coordinates.is_a?(String)
      @area.coordinates = JSON.parse(@area.coordinates)
    end

    respond_to do |format|
      if @area.save
        format.html { redirect_to admin_areas_path, notice: "Area was successfully created." }
        format.json { render :show, status: :created, location: @area }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @area.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def area_params
      params.expect(area: [ :name, :coordinates ])
    end
end
