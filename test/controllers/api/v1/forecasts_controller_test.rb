require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  success_geocode_payload = { "status" => "OK", "results" => [ { "geometry" => { "location" => { "lat" => 39.7392, "lng" => -104.9903 } } } ] }
  not_found_geocode_payload = { "status" => "ZERO_RESULTS" }

  test "should get success payload" do
    Http::GoogleGeocodingClient
      .any_instance
      .stubs(:geocode)
      .returns(success_geocode_payload)

    get api_v1_forecast_path(address: "Denver, CO")

    assert_response :success
    assert_includes response.body, "cache"
    assert_includes response.body, "low"
    assert_includes response.body, "high"
    assert_includes response.body, "description"
  end

  test "should return not found error for invalid address" do
    Http::GoogleGeocodingClient
      .any_instance
      .stubs(:geocode)
      .returns(not_found_geocode_payload)

    get api_v1_forecast_path(address: "Denver, CO")

    assert_response :not_found
  end

  test "should return bad request error without address parameter" do
    get api_v1_forecast_path

    assert_response :bad_request
    assert includes response.body, "address is required"
  end
end
