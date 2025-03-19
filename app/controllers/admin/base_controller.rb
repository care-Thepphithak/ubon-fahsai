class Admin::BaseController < ApplicationController
  layout "dashboard"

  before_action :require_admin
  skip_before_action :restrict_by_user_role
end
