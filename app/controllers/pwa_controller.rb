class PwaController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :service_worker
  layout false

  def service_worker
    render :service_worker, content_type: "application/javascript"
  end

  def manifest
    render json: {
      "name": "UbonFahsai",
      "icons": [
        {
          "src": "/icon.png",
          "type": "image/png",
          "sizes": "512x512"
        },
        {
          "src": "/icon.png",
          "type": "image/png",
          "sizes": "512x512",
          "purpose": "maskable"
        }
      ],
      "start_url": "/",
      "display": "standalone",
      "scope": "/",
      "description": "UbonFahsai.",
      "theme_color": "#FF6159",
      "background_color": "#FF6159"
    }
  end
end
