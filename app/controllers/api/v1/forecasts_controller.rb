class Api::V1::ForecastsController < ApplicationController
  def show
    address = params[:address]
    forecast = Forecasts::FindOrCreateService.new(address).call

    render json: forecast, status: :ok
  end
end
