module Efacturapty
  # Thin wrapper around a parsed JSON response body.
  # Exposes keys as methods and provides Hash-like access.
  class Response
    attr_reader :body, :status

    def initialize(body, status)
      @body   = body
      @status = status
    end

    # Delegate unknown method calls to the underlying hash.
    # e.g. +resp.cufe+, +resp.autorizada+
    def method_missing(name, *args)
      key = name.to_s
      if @body.is_a?(Hash) && @body.key?(key)
        @body[key]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      (@body.is_a?(Hash) && @body.key?(name.to_s)) || super
    end

    def [](key)
      @body.is_a?(Hash) ? @body[key.to_s] : nil
    end

    def to_h
      @body.is_a?(Hash) ? @body : {}
    end

    def to_a
      @body.is_a?(Array) ? @body : []
    end
  end
end
