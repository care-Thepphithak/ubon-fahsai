class Admin::AreasController < ApplicationController
  def index
  end

  def new
    @area = Area.new
  end

  def create
    @area = Area.new(area_params)

    respond_to do |format|
      if @area.save
        format.html { redirect_to admin_areas_path, notice: @area.location_name }
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
      params.expect(area: [ :name ])
    end
end
