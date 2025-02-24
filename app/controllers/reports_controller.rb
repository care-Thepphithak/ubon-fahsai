class ReportsController < ApplicationController
  allow_unauthenticated_access

  # GET /reports or /reports.json
  def index
    @report = Report.new
  end

  # POST /reports or /reports.json
  def create
    @report = Report.new(report_params)

    respond_to do |format|
      if @report.save
        ActionCable.server.broadcast("report_channel", { message: @report })
        format.html { redirect_to reports_path, notice: "Report was successfully created." }
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
