class ApplicationController < ActionController::Base
  include Authentication
  include TrendComparison

  allow_browser versions: :modern unless Rails.env.development?
end
