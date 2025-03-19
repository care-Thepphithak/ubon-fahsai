module Admin
  class DashboardController < BaseController
    def index
      @reports = Report.all.order(created_at: :desc)
      @reports = @reports.today if params[:filter] != "all"

      @total_today_report = @reports.today.count
      total_yesterday_report = @reports.yesterday.count
      @total_today_harmful_report = @reports.today.harmful.count

      @top_districts = Report.top_districts
      @areas = Area.all

      @report_trend = compare_counts(@total_today_report, total_yesterday_report)

      @harmful_report_trend = compare_counts(
        @reports.today.harmful.count,
        @reports.yesterday.harmful.count)
    end
  end
end
