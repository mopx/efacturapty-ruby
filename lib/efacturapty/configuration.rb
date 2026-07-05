module Efacturapty
  # Holds all configuration for an Efacturapty client.
  #
  #   Efacturapty.configure do |c|
  #     c.client_id     = ENV["EFACTURAPTY_CLIENT_ID"]
  #     c.client_secret = ENV["EFACTURAPTY_CLIENT_SECRET"]
  #   end
  #
  class Configuration
    API_BASE_URL  = "https://api.efacturapty.com".freeze
    AUTH_BASE_URL = "https://sec.efacturapty.com".freeze
    DEFAULT_SCOPE = "apiApplication".freeze

    attr_accessor :client_id,
                  :client_secret,
                  :api_key,
                  :scope,
                  :api_base_url,
                  :auth_base_url,
                  :open_timeout,
                  :read_timeout,
                  :logger,
                  :validate_invoices

    def initialize
      @api_base_url       = API_BASE_URL
      @auth_base_url      = AUTH_BASE_URL
      @scope              = DEFAULT_SCOPE
      @open_timeout       = 5
      @read_timeout       = 30
      @logger             = nil
      @validate_invoices  = true
    end

    def validate!
      return unless blank?(api_key)

      raise ConfigurationError, "client_id is required"     if blank?(client_id)
      raise ConfigurationError, "client_secret is required" if blank?(client_secret)
    end

    private

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end
  end
end
