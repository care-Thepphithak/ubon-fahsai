class Admin::DashboardController < ApplicationController
  def index
    @reports = Report.all.order(created_at: :desc)
    @report_count = Report.count
    @report_harmful_count = Report.where(severity_level: "วิกฤติ").count
    @top_locations = Report.select("split_part(reverse(split_part(reverse(location_name), 'จังหวัด', 1)), ' ', -2) AS district, COUNT(*) AS district_count").where("location_name LIKE ?", "%จังหวัด%").group("district").order(Arel.sql("district_count DESC")).limit(3)
  end
end
