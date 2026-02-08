# frozen_string_literal: true

module Weather
  class FindOrFetchService
    def initialize(address)
      @address = address
    end

    def call
      weather_data = Http::OpenMeteoClient.new.forecast(
        latitude: @address["lat"],
        longitude: @address["lng"]
      )

      raise NotFoundError, "Weather not found" unless weather_data["error"].nil?
      Rails.logger.debug weather_data

      {
        temperature: weather_data["current"]["temperature_2m"],
        unit: weather_data["current_units"]["temperature_2m"],
        daily: (0..6).map do |index|
          {
            date: weather_data["daily"]["time"][index],
            max_temp: weather_data["daily"]["temperature_2m_max"][index],
            min_temp: weather_data["daily"]["temperature_2m_min"][index]
          }
        end
      }
    end
  end
end
