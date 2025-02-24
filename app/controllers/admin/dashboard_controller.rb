class Admin::DashboardController < ApplicationController
  def index
    @reports = Report.all.order(created_at: :desc)
    @report_count = Report.count
    @report_harmful_count = Report.count_harmful_reports
    @top_districts = Report.top_districts

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
