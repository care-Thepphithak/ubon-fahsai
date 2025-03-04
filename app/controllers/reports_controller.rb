class ReportsController < ApplicationController
  before_action :require_client
  skip_before_action :restrict_by_user_role

  # GET /reports or /reports.json
  def index
    @report = Report.new
    @user_areas = Current.user.areas.map(&:coordinates).to_json
  end

  # POST /reports or /reports.json
  def create
    @report = Report.new(report_params)

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
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def report_params
      params.expect(report: [ :lat, :long, :location_name, :description, :tags, :severity_level,  images: [] ])
    end
end
