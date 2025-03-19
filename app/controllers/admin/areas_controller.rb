module Admin
  class AreasController < BaseController
    def index
      @areas = Area.sorted_by_created_at
    end

    def new
      @area = Area.new
    end

    def edit
      @area = Area.find(params[:id])
    end

    def update
      @area = Area.find(params[:id])

      respond_to do |format|
        if @area.update(area_params)
          format.html { redirect_to admin_areas_path }
          format.json { render :show, status: :ok, location: @area }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @area.errors, status: :unprocessable_entity }
        end
      end
    end

    def create
      @area = Area.new(area_params)

      respond_to do |format|
        if @area.save
          format.html { redirect_to admin_areas_path }
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
      expected_params = params.expect(area: [ :name, :coordinates, user_ids: [] ])
      parsed_coordinates = JSON.parse(expected_params[:coordinates])
      expected_params.merge coordinates: parsed_coordinates
    end
  end
end
