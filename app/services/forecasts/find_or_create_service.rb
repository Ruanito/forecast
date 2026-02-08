# frozen_string_literal: true

module Forecasts
  class FindOrCreateService
    def initialize(zipcode)
      @zipcode = zipcode
    end

    def call
      Rails.cache.fetch("forecasts_#{@zipcode}", expires_in: 30.minutes) do
        address = Address::FindOrFetchService.new(@zipcode).call
        weather = Weather::FindOrFetchService.new(address).call

        {
          weather: weather
        }
      end
    end
  end
end
