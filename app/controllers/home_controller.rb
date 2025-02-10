class HomeController < ApplicationController
  def index
    @reports = Report.all.order(created_at: :desc)
  end
end
