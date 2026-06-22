require "net/http"
require "uri"
require "json"

module Efacturapty
  # Manages an OAuth2 client_credentials token from the efacturapty IdentityServer.
  # Caches the access_token and refreshes it automatically 60 seconds before expiry.
  # Thread-safe via a Mutex.
  class Token
    GRANT_TYPE    = "client_credentials".freeze
    EXPIRY_BUFFER = 60 # seconds before actual expiry to refresh

    def initialize(config)
      @config     = config
      @mutex      = Mutex.new
      @token      = nil
      @expires_at = nil
    end

    # Returns a valid Bearer token string, fetching a new one if needed.
    def access_token
      @mutex.synchronize do
        fetch! if expired?
        @token
      end
    end

    private

    def expired?
      @token.nil? || @expires_at.nil? || Time.now.to_i >= @expires_at
    end

    def fetch!
      response = post_token_request
      data     = parse_token_response(response)
      store_token(data)
    end

    # rubocop:disable Metrics/MethodLength
    def post_token_request
      http    = build_http
      request = Net::HTTP::Post.new(token_uri.path)
      request.set_form_data(
        "grant_type" => GRANT_TYPE,
        "client_id" => @config.client_id,
        "client_secret" => @config.client_secret,
        "scope" => @config.scope
      )
      response = http.request(request)
      unless response.is_a?(Net::HTTPSuccess)
        raise AuthenticationError,
              "Token request failed (HTTP #{response.code}): #{response.body}"
      end
      response
    end
    # rubocop:enable Metrics/MethodLength

    def build_http
      http              = Net::HTTP.new(token_uri.host, token_uri.port)
      http.use_ssl      = token_uri.scheme == "https"
      http.open_timeout = @config.open_timeout
      http.read_timeout = @config.read_timeout
      http
    end

    def token_uri
      @token_uri ||= URI("#{@config.auth_base_url}/connect/token")
    end

    def parse_token_response(response)
      JSON.parse(response.body)
    end

    def store_token(data)
      @token = data.fetch("access_token") do
        raise AuthenticationError, "No access_token in response"
      end
      expires_in  = data.fetch("expires_in", 3600).to_i
      @expires_at = Time.now.to_i + expires_in - EXPIRY_BUFFER
    end
  end
end
