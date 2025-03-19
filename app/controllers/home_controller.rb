class HomeController < ApplicationController
  before_action :require_client
  skip_before_action :restrict_by_user_role

  def index
    @reports = Report.all.order(created_at: :desc)
    @report_count = Report.count_today
    @user_areas_exist = Current.user.areas.any?

    @report_count_comparisons = {
      more: Report.count_today > Report.count_yesterday,
      less: Report.count_today < Report.count_yesterday
    }
  end
end
