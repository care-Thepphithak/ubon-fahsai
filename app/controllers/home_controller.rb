class HomeController < ApplicationController
  allow_unauthenticated_access

  def index
    @reports = Report.all.order(created_at: :desc)
  end
end
