class ReportsController < BaseController
  def index
    @report = Report.new
    @user_areas = current_user_areas

    redirect_to root_path if @user_areas == "[]"
  end

  def create
    @report = Report.new(report_params)
    @reports = Report.all

    respond_to do |format|
      if @report.save
        format.html { redirect_to root_path, notice: @report.location_name }
        format.json { render :show, status: :created, location: @report }
      else
        format.turbo_stream { render_report_creation_error }
      end
    end
  end

  private
    def report_params
      expected_params = params.expect(report: [ :lat, :long, :location_name, :description, :tags, :severity_level, :area_ids, images: [] ])
      area_id_array = expected_params[:area_ids].split(",").map(&:to_i)
      expected_params.merge(area_ids: area_id_array)
    end

    def render_report_creation_error
      location_error = @report.errors.full_messages.join("<br/>")
      error_html = "<p class='mt-2 text-base w-[80%] mx-auto text-gray-500'>#{location_error}</p>"
      render turbo_stream: turbo_stream.update("location-name", error_html.html_safe)
    end

    def current_user_areas
      Current.user.areas.sorted_by_created_at.map { |area| { "#{area.id}" => area.coordinates } }.to_json
    end
end
