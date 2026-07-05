module Efacturapty
  # Holds all configuration for an Efacturapty client.
  #
  #   Efacturapty.configure do |c|
  #     c.api_key = ENV["EFACTURAPTY_API_KEY"]
  #   end
  #
  class Configuration
    API_BASE_URL = "https://api.efacturapty.com".freeze

    attr_accessor :api_key,
                  :api_base_url,
                  :open_timeout,
                  :read_timeout,
                  :logger,
                  :validate_invoices

    def initialize
      @api_base_url       = API_BASE_URL
      @open_timeout       = 5
      @read_timeout       = 30
      @logger             = nil
      @validate_invoices  = true
    end

    def validate!
      raise ConfigurationError, "api_key is required" if blank?(api_key)
    end

    private

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end
  end
end
