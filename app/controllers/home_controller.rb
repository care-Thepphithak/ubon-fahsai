class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @reports = Report.all.order(created_at: :desc)
    @report_count = Report.count_today
  end
end
