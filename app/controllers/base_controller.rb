class BaseController < ApplicationController
  before_action :require_client
  skip_before_action :restrict_by_user_role
end
