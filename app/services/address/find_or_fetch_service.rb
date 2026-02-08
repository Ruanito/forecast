# frozen_string_literal: true

module Address
  class FindOrFetchService
    def initialize(zipcode)
      @zipcode = zipcode
    end

    def call
      location = Location.find_by(zipcode: @zipcode)

      return location.serializable_hash if location

      geocode = Http::GoogleGeocodingClient.new.geocode(@zipcode)
      raise NotFoundError, "Address not found: #{@zipcode}" if geocode["status"] == "ZERO_RESULTS"

      coords = geocode.dig("results", 0, "geometry", "location")

      Location.create!({ zipcode: @zipcode, lat: coords["lat"], lng: coords["lng"] }).serializable_hash
    end
  end
end
