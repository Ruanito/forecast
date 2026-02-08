# frozen_string_literal: true

module Http
  class OpenMeteoClient < BaseClient
    def initialize
      super(base_url: "https://api.open-meteo.com/v1")
    end

    def forecast(latitude:, longitude:)
      get("forecast", params: { latitude: latitude, longitude: longitude, daily: "temperature_2m_max,temperature_2m_min", timezone: "auto", current: "temperature_2m" })
    end
  end
end
