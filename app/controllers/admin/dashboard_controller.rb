class Admin::DashboardController < ApplicationController
  layout "dashboard"

  before_action :require_admin
  skip_before_action :restrict_by_user_role

  def index
    @reports = filtered_reports
    @report_count = Report.count_today
    @report_harmful_count = Report.count_harmful_today
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

  private

  def filtered_reports
    reports = Report.all.order(created_at: :desc)
    return reports if params[:filter] == "all"
    reports.where("created_at >= ?", Time.zone.today.beginning_of_day)
  end
end
