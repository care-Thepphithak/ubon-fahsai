class Admin::DashboardController < ApplicationController
  def index
    @reports = Report.all.order(created_at: :desc)
    @reports_with_images_url = @reports.map do |report|
      images_urls = report.images.attached? ? report.images.map { |img| url_for(img) } : []
      report.attributes.merge({ "images_urls" => images_urls })
    end
  end
end
