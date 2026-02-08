# frozen_string_literal: true

module Forecasts
  class FindOrCreateService
    def initialize(zipcode)
      @zipcode = zipcode
    end

    def call
      address = Address::FindOrFetchService.new(@zipcode).call
      weather = Weather::FindOrFetchService.new(address).call

      {
        weather: weather
      }
    end
  end
end
