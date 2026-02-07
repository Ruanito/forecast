require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get api_v1_forecast_path

    assert_response :success
    assert_includes response.body, "cache"
    assert_includes response.body, "low"
    assert_includes response.body, "high"
    assert_includes response.body, "description"
  end
end
