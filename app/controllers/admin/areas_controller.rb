module Admin
  class AreasController < BaseController
    before_action :set_all_user, only: [ :new, :edit, :create, :update ]

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
      formmated_area_params = area_params.merge coordinates: JSON.parse(area_params[:coordinates])

      respond_to do |format|
        if @area.update(formmated_area_params)
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
      @area.coordinates = JSON.parse(@area.coordinates)

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
        params.expect(area: [ :name, :coordinates, user_ids: [] ])
      end

      def set_all_user
        @users = User.where(admin: false)
      end
  end
end
