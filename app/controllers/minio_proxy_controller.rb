class MinioProxyController < ApplicationController
  require "net/http"
  require "uri"

  # You may want to skip authentication or CSRF for this endpoint
  skip_before_action :verify_authenticity_token

  def proxy
    file_key = params[:key]
    # Build the MinIO URI using your HTTP endpoint.
    uri = URI.parse("http://40.81.22.86:9000/#{file_key}")
    uri.query = request.query_string if request.query_string.present?

    # Stream the file with Net::HTTP
    http_response = Net::HTTP.get_response(uri)
    if http_response.code == "200"
      content_type = http_response.content_type || "application/octet-stream"
      send_data http_response.body,
        disposition: "inline",
        type: content_type
    else
      head http_response.code.to_i
    end
  rescue => e
    Rails.logger.error "MinIO proxy error: #{e.message}"
    head :bad_gateway
  end
end
