require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  success_geocode_payload = {
    "status" => "OK",
    "results" => [
      {
        "geometry" => {
          "location" => { "lat" => 39.7392, "lng" => -104.9903 }
        }
      }
    ]
  }

  weather_payload = {
    "current_units" => {
      "time" => "iso8601",
      "interval" => "seconds",
      "temperature_2m" => "°C"
    },
    "current" => {
      "time" => "2026-02-08T12:15",
      "interval" => 900,
      "temperature_2m" => 23.8
    },
    "daily" => {
      "time" => %w[2026-02-08 2026-02-09 2026-02-10 2026-02-11 2026-02-12 2026-02-13 2026-02-14],
      "temperature_2m_max" => [
        24.8,
        25.5,
        28.7,
        29.1,
        30.4,
        29.0,
        28.7
      ],
      "temperature_2m_min" => [
        17.5,
        16.3,
        15.9,
        17.7,
        17.9,
        18.0,
        18.6
      ]
    }
  }

  test "should get success payload" do
    Http::GoogleGeocodingClient
      .any_instance
      .stubs(:geocode)
      .returns(success_geocode_payload)

    Http::OpenMeteoClient
      .any_instance
      .stubs(:forecast)
      .returns(weather_payload)

    get api_v1_forecast_path(zipcode: "12345")

    assert_response :success
    assert_includes response.body, "weather"
    assert_includes response.body, "temperature"
  end

  test "should return response for new zipcode" do
    Http::GoogleGeocodingClient
      .any_instance
      .stubs(:geocode)
      .returns(success_geocode_payload)

    Http::OpenMeteoClient
      .any_instance
      .stubs(:forecast)
      .returns(weather_payload)

    get api_v1_forecast_path(zipcode: "22222")

    assert_response :success
    assert_includes response.body, "weather"
    assert_includes response.body, "temperature"

    response_data = JSON.parse(response.body)

    assert_equal 23.8, response_data["weather"]["temperature"]
    assert_equal "°C", response_data["weather"]["unit"]
    assert_equal 7, response_data["weather"]["daily"].length
  end

  test "should return not found error for invalid address" do
    success_geocode_payload = {
      "status" => "OK",
      "results" => [
        {
          "geometry" => {
            "location" => { "lat" => 39.7392, "lng" => -104.9903 }
          }
        }
      ]
    }

    error_weather_payload = { "error" => "Invalid coordinates" }

    Http::OpenMeteoClient
      .any_instance
      .stubs(:forecast)
      .returns(error_weather_payload)

    Http::GoogleGeocodingClient
      .any_instance
      .stubs(:geocode)
      .returns(success_geocode_payload)

    get api_v1_forecast_path(zipcode: "11111")

    assert_response :not_found
  end

  test "should return not found error for weather error" do
    not_found_geocode_payload = { "status" => "ZERO_RESULTS" }
    Http::GoogleGeocodingClient
      .any_instance
      .stubs(:geocode)
      .returns(not_found_geocode_payload)

    get api_v1_forecast_path(zipcode: "11111")

    assert_response :not_found
  end

  test "should return bad request error without address parameter" do
    get api_v1_forecast_path

    assert_response :bad_request
    assert includes response.body, "address is required"
  end
end
