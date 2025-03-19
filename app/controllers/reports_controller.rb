class ReportsController < BaseController

  # GET /reports or /reports.json
  def index
    @report = Report.new
    @user_areas = Current.user.areas.sorted_by_created_at.map { |area| { "#{area.id}" => area.coordinates } }.to_json

    if @user_areas == "[]"
      redirect_to root_path
    end
  end

  # POST /reports or /reports.json
  def create
    area_ids_arr = report_params[:area_ids].split(",").map(&:to_i)
    @report = Report.new(report_params.merge(area_ids: area_ids_arr))

    respond_to do |format|
      if @report.save
        ActionCable.server.broadcast("report_channel", {
          message: @report,
          total_count: Report.count_today,
          harmful_count: Report.count_harmful_today,
          top_districts: Report.top_districts.map { |report| { district: report.district, district_count: report.district_count } }
        })
        format.html { redirect_to root_path, notice: @report.location_name }
        format.json { render :show, status: :created, location: @report }
      else
        format.turbo_stream do
          location_error = @report.errors.map { |error| error.message }.join("<br/>")
          error_html = "<p class='mt-2 text-base w-[80%] mx-auto text-gray-500'>#{location_error}</p>"
          render turbo_stream: turbo_stream.update("location-name", error_html.html_safe)
        end
      end
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def report_params
      params.expect(report: [ :lat, :long, :location_name, :description, :tags, :severity_level, :area_ids, images: [] ])
    end
end
