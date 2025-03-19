module Admin
  class DashboardController < BaseController
    def index
      @reports = Report.all.order(created_at: :desc)
      @reports = @reports.today if params[:filter] != "all"
      @report_count = @reports.today.count
      @report_harmful_count = @reports.today.harmful.count

      @top_districts = Report.top_districts
      @areas = Area.all

      @report_count_comparisons = {
        more: Report.count_today > Report.count_yesterday,
        less: Report.count_today < Report.count_yesterday
      }

      @report_harmful_count_comparisons = {
        more: Report.count_harmful_today > Report.count_harmful_yesterday,
        less: Report.count_harmful_today < Report.count_harmful_yesterday
      }
    end
  end
end
