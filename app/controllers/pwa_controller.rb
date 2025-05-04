class PwaController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :service_worker, :manifest ]
  allow_unauthenticated_access only: %i[service_worker manifest]
  layout false

  def service_worker
    render :service_worker, content_type: "application/javascript"
  end

  def manifest
    render :manifest, content_type: "application/manifest+json"
  end
end
