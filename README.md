# Forecast API — Application Documentation

A Ruby on Rails API that returns weather forecasts for a given **zipcode**. It resolves the zipcode to coordinates via geocoding, fetches weather data from an external provider, and caches results to reduce external calls.

## Overview

The application exposes a REST API that:

1. Accepts a **zipcode** as a query parameter.
2. Resolves the zipcode to an address and coordinates (geocoding).
3. Fetches current and 7-day weather data for those coordinates.
4. Returns a JSON payload with current temperature and daily min/max temperatures.

Geocoding uses **Google Geocoding API**; weather data comes from **Open-Meteo**. Results are cached per zipcode and persisted in the database (Solid Cache) in production.

---

## Main Flow

1. **Request**  
   `GET /api/v1/forecast?zipcode=12345`

2. **Controller**  
   Requires `zipcode`, calls `Forecasts::FindOrCreateService.new(zipcode).call`, returns JSON.

3. **Forecasts::FindOrCreateService**
    - Tries to read from cache with key `forecasts_<zipcode>` (expires in 30 minutes).
    - On cache miss:
        - Calls **Address::FindOrFetchService** to get `{ zipcode, lat, lng }` (from DB or Google Geocoding).
        - Calls **Weather::FindOrFetchService** with that address to get weather from Open-Meteo.
        - Builds `{ weather: ... }` and stores it in the cache.

4. **Response**  
   JSON with `weather` (current temperature, unit, and 7 days of min/max).

---

### Get Forecast

Returns current weather and 7-day daily min/max temperatures for the given zipcode.

- **Method:** `GET`
- **Path:** `/api/v1/forecast`
- **Query parameters:**
    - `zipcode` (string, required) — Zipcode to resolve and get weather for.

**Example request**

```bash
curl "http://localhost:3000/api/v1/forecast?zipcode=22222"
```

**Example 200 OK response**

```json
{
  "weather": {
    "temperature": 23.8,
    "unit": "°C",
    "daily": [
      { "date": "2026-02-08", "max_temp": 24.8, "min_temp": 17.5 },
      { "date": "2026-02-09", "max_temp": 25.5, "min_temp": 16.3 },
      { "date": "2026-02-10", "max_temp": 28.7, "min_temp": 15.9 },
      { "date": "2026-02-11", "max_temp": 29.1, "min_temp": 17.7 },
      { "date": "2026-02-12", "max_temp": 30.4, "min_temp": 17.9 },
      { "date": "2026-02-13", "max_temp": 29.0, "min_temp": 18.0 },
      { "date": "2026-02-14", "max_temp": 28.7, "min_temp": 18.6 }
    ]
  }
}
```

### Errors

| Status | Condition | Response body |
|--------|-----------|----------------|
| **400 Bad Request** | Missing `zipcode` parameter | `{ "error": "zipcode is required" }` |
| **404 Not Found** | Zipcode could not be geocoded (e.g. ZERO_RESULTS) or weather API returned an error | `{ "error": "Resource not found" }` |
| **500 Internal Server Error** | Unexpected errors (e.g. HTTP/client failures) | Standard Rails error response |

---

## Caching

- **What is cached:** The full `{ weather: ... }` hash per zipcode.
- **Cache key:** `forecasts_<zipcode>` (e.g. `forecasts_22222`).
- **TTL:** 30 minutes (defined in `Forecasts::FindOrCreateService`).

**Behavior:**

- If a valid cache entry exists, it is returned without calling geocoding or weather APIs.
- On cache miss, the service runs geocoding → weather fetch → then stores the result in the cache.

## Technical Decisions

- **Service objects** — `Forecasts::FindOrCreateService`, `Address::FindOrFetchService`, and `Weather::FindOrFetchService` keep controllers thin and encapsulate business logic and external integrations.
- **HTTP clients** — Geocoding and weather are behind `Http::*` clients, making it easy to stub in tests and to change providers later.
- **Caching** — Rails cache with a per-zipcode key and 30-minute TTL reduces calls to Google and Open-Meteo and improves response time for repeated zipcodes.
- **Persistence of locations** — Resolved zipcodes are stored in `locations` so repeated requests for the same zipcode can skip geocoding when the cache has expired but the location is already in the DB (used by `Address::FindOrFetchService`).
- **Error handling** — `ApplicationController` uses `rescue_from` for `NotFoundError` (404) and `ActionController::ParameterMissing` (400), returning consistent JSON error bodies.
