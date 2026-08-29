module Efacturapty
  # Base error for all gem-level exceptions.
  class Error < StandardError; end

  # Raised when the client is created with missing or invalid configuration.
  class ConfigurationError < Error; end

  # Raised by {InvoiceValidator} when a payload fails client-side pre-flight
  # checks, before any HTTP request is made. Not an {ApiError} subclass —
  # there is no HTTP status/body, since the API was never contacted.
  class ValidationError < Error
    attr_reader :errors

    def initialize(errors)
      @errors = Array(errors)
      super("Invoice payload is invalid: #{@errors.join('; ')}")
    end
  end

  # Base class for errors returned from the efacturapty HTTP API.
  # Carries the HTTP status code and the parsed response body.
  class ApiError < Error
    attr_reader :status, :body

    def initialize(message, status: nil, body: nil)
      super(message)
      @status = status
      @body   = body
    end

    # Build the right subclass from a Faraday response.
    # rubocop:disable-next Metrics/MethodLength
    def self.from_response(response)
      status = response.status
      body   = response.body
      msg    = extract_message(body, status)

      klass =
        case status
        when 400, 422 then BadRequestError
        when 401      then AuthenticationError
        when 404      then NotFoundError
        when 429      then RateLimitError
        when 500..599 then ServerError
        else ApiError
        end

      klass.new(msg, status: status, body: body)
    end

    def self.extract_message(body, status)
      if body.is_a?(Hash)
        body["message"] || body["error"] || body["title"] || "API error (HTTP #{status})"
      else
        "API error (HTTP #{status})"
      end
    end
    private_class_method :extract_message
  end

  # 401 — bad or expired api_key.
  class AuthenticationError < ApiError; end

  # 400 / 422 — bad request or validation failure.
  class BadRequestError < ApiError; end

  # 404 — resource not found.
  class NotFoundError < ApiError; end

  # 429 — rate limit exceeded.
  class RateLimitError < ApiError; end

  # 5xx — server-side error.
  class ServerError < ApiError; end
end
