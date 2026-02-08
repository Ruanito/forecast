class Api::V1::ForecastsController < ApplicationController
  def show
    zipcode = params.require(:zipcode)
    forecast = Forecasts::FindOrCreateService.new(zipcode).call

    render json: forecast, status: :ok
  end
end
