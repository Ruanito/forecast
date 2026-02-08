# frozen_string_literal: true

module Http
  class BaseClient
    def initialize(base_url:)
      @conn = Faraday.new(url: base_url) do |faraday|
        faraday.adapter Faraday.default_adapter
      end
    end

    def get(path, params: {})
      response = @conn.get(path, params)

      raise "HTTP Error: #{response.status}" unless response.success?

      JSON.parse(response.body)
    end
  end
end
