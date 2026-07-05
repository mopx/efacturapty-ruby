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

    # Matches the "Accept" header sent by the official efacturapty API docs/examples.
    DEFAULT_ACCEPT = "text/plain, application/json, text/json".freeze

    # Content type the DGI API expects for JSON request bodies.
    JSON_PATCH_CONTENT_TYPE = "application/json-patch+json".freeze

    attr_reader :config

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
        req.headers.merge!(default_headers)
        req.headers.merge!(headers) unless headers.empty?
      end
      handle(response)
    end

    def post(path, body = {}, params = {}, headers = {})
      response = connection.post(path) do |req|
        req.params.merge!(params) unless params.empty?
        req.headers.merge!(post_headers(body, headers))
        req.body = encode_body(body)
      end
      handle(response)
    end

    # Binary GET — returns raw body bytes, no JSON parsing.
    def get_raw(path, params = {}, headers = {})
      response = connection.get(path) do |req|
        req.params.merge!(params) unless params.empty?
        req.headers.merge!(default_headers)
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
        f.request :retry, RETRY_OPTIONS
        f.response :json, content_type: /\bjson\b/
        f.response :logger, cfg.logger if cfg.logger
        f.adapter Faraday.default_adapter
      end
    end

    def default_headers
      { "Accept" => DEFAULT_ACCEPT }.merge(auth_header)
    end

    def post_headers(body, headers)
      content_type = json_body?(body) ? { "Content-Type" => JSON_PATCH_CONTENT_TYPE } : {}
      default_headers.merge(content_type).merge(headers)
    end

    def auth_header
      { "Authorization" => "Bearer #{@token.access_token}" }
    end

    def json_body?(body)
      !body.nil? && !(body.respond_to?(:empty?) && body.empty?) && !body.is_a?(String)
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
