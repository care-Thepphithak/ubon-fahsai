class MinioProxyController < ApplicationController
  require "aws-sdk-s3"

  skip_before_action :verify_authenticity_token

  def proxy
    s3_client = Aws::S3::Client.new(
      access_key_id: ENV["MINIO_ROOT_USER"],
      secret_access_key: ENV["MINIO_ROOT_PASSWORD"],
      endpoint: ENV["MINIO_ENDPOINT"] || "http://10.11.0.50:9000",
      region: "us-east-1",
      force_path_style: true
    )

    bucket = ENV["MINIO_BUCKET"]
    file_key = params[:key]

    signer = Aws::S3::Presigner.new(client: s3_client)
    url = signer.presigned_url(:get_object, bucket: bucket, key: file_key, expires_in: 300)

    # Fetch the file using the signed URL
    uri = URI.parse(url)
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
