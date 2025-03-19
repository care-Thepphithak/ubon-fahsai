class BaseController < ApplicationController
  before_action :protect_admin_access
end
