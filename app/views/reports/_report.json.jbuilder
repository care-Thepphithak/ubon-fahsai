json.extract! report, :id, :lat, :long, :created_at, :updated_at
json.url report_url(report, format: :json)
