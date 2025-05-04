class Admin::BaseController < ApplicationController
  layout "dashboard"
  before_action :protect_client_access
end
