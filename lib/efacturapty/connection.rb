require "faraday"
require "faraday/retry"

module Efacturapty
  # Builds and memoizes a Faraday connection for the efacturapty API.
  # Handles JSON encoding/decoding, Bearer token injection, and retries.
  class Connection
    RETRY_OPTIONS = {
      max: 2,
      interval: 0.5,
      retry_statuses: [429, 503]
    }.freeze

    def initialize(config, token)
      @config = config
      @token  = token
    end

    def connection
      @connection ||= build_connection
    end

    # Execute a JSON request. Returns a Response or raises an ApiError subclass.
    def get(path, params = {}, headers = {})
      response = connection.get(path) do |req|
        req.params.merge!(params) unless params.empty?
        req.headers.merge!(auth_header)
        req.headers.merge!(headers) unless headers.empty?
      end
      handle(response)
    end

    def post(path, body = {}, params = {}, headers = {})
      response = connection.post(path) do |req|
        req.params.merge!(params) unless params.empty?
        req.headers.merge!(auth_header)
        req.headers.merge!(headers) unless headers.empty?
        req.body = encode_body(body)
      end
      handle(response)
    end

    # Binary GET — returns raw body bytes, no JSON parsing.
    def get_raw(path, params = {}, headers = {})
      response = connection.get(path) do |req|
        req.params.merge!(params) unless params.empty?
        req.headers.merge!(auth_header)
        req.headers.merge!(headers) unless headers.empty?
      end
      raise ApiError.from_response(wrap_raw(response)) unless response.success?

      response.body
    end

    private

    def build_connection
      cfg = @config
      Faraday.new(url: cfg.api_base_url) do |f|
        f.options.open_timeout = cfg.open_timeout
        f.options.timeout      = cfg.read_timeout
        f.request :json
        f.request :retry, RETRY_OPTIONS
        f.response :json, content_type: /\bjson\b/
        f.response :logger, cfg.logger if cfg.logger
        f.adapter Faraday.default_adapter
      end
    end

    def auth_header
      { "Authorization" => "Bearer #{@token.access_token}" }
    end

    def encode_body(body)
      return nil if body.nil? || body.empty?

      body.is_a?(String) ? body : body.to_json
    end

    def handle(response)
      raise ApiError.from_response(response) unless response.success?

      Response.new(response.body, response.status)
    end

    # Wrap a Faraday response in a duck-typed object ApiError.from_response expects.
    def wrap_raw(response)
      Struct.new(:status, :body).new(response.status, response.body)
    end
  end
end
