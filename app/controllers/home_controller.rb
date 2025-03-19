class HomeController < BaseController
  def index
    @reports = Report.all.order(created_at: :desc)
    @total_today_report = @reports.today.count
    total_yesterday_report = @reports.yesterday.count
    @user_areas_exist = Current.user.areas.any?
    @report_trend = compare_counts(@total_today_report, total_yesterday_report)
  end
end
