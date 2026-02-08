class ApplicationController < ActionController::API
  rescue_from NotFoundError, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def render_not_found(e)
    Rails.logger.warn("[ApplicationController] NotFoundError: #{e.message}")
    render json: { error: "Resource not found" }, status: :not_found
  end

  def render_bad_request(e)
    render json: { error: "#{e.param} is required" }, status: :bad_request
  end
end
