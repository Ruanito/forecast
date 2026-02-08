# frozen_string_literal: true

module Http
  class GoogleGeocodingClient < BaseClient
    def initialize
      super(base_url: "https://maps.googleapis.com/maps/api")
    end

    def geocode(address)
      Rails.logger.debug("[GoogleGeocodingClient] [geocode] Geocoding address: #{address}")
      get("geocode/json", params: { address: address, key: ENV["GOOGLE_MAPS_API_KEY"] })
    end
  end
end
