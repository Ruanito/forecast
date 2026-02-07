# frozen_string_literal: true

module Forecasts
  class FindOrCreateService
    def initialize(address)
      @address = address
    end

    def call
      {
        low: rand(10..20),
        high: rand(20..30),
        description: "Sunny with a chance of rain",
        cache: false
      }
    end
  end
end
