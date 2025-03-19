class ApplicationController < ActionController::Base
  include Authentication
  include TrendComparison
  before_action :restrict_by_user_role
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern unless Rails.env.development?
end
