require_relative "configuration"
require_relative "errors"
require_relative "token"
require_relative "connection"
require_relative "response"
require_relative "resources/base_resource"
require_relative "resources/invoices"
require_relative "resources/invoice_events"
require_relative "resources/catalogs"
require_relative "resources/subscriptions"
require_relative "resources/taxpayers"

module Efacturapty
  # The main entry point for interacting with the efacturapty API.
  #
  # Instantiate with explicit credentials:
  #
  #   client = Efacturapty::Client.new(
  #     client_id:     "your-client-id",
  #     client_secret: "your-client-secret"
  #   )
  #
  # Or use the global configuration:
  #
  #   Efacturapty.configure { |c| c.client_id = "..." }
  #   client = Efacturapty.client
  #
  class Client
    # @return [Configuration]
    attr_reader :config

    def initialize(options = {})
      @config = build_config(options)
      @config.validate!
    end

    # Access Invoices resource methods.
    # @return [Resources::Invoices]
    def invoices
      @invoices ||= Resources::Invoices.new(connection)
    end

    # Access InvoiceEvents resource methods.
    # @return [Resources::InvoiceEvents]
    def invoice_events
      @invoice_events ||= Resources::InvoiceEvents.new(connection)
    end

    # Access Catalogs resource methods.
    # @return [Resources::Catalogs]
    def catalogs
      @catalogs ||= Resources::Catalogs.new(connection)
    end

    # Access Subscriptions resource methods.
    # @return [Resources::Subscriptions]
    def subscriptions
      @subscriptions ||= Resources::Subscriptions.new(connection)
    end

    # Access Taxpayers resource methods.
    # @return [Resources::Taxpayers]
    def taxpayers
      @taxpayers ||= Resources::Taxpayers.new(connection)
    end

    private

    def token
      @token ||= Token.new(@config)
    end

    def connection
      @connection ||= Connection.new(@config, token)
    end

    def build_config(options)
      if options.empty?
        Efacturapty.configuration
      else
        cfg = Configuration.new
        options.each do |key, value|
          cfg.public_send(:"#{key}=", value)
        end
        cfg
      end
    end
  end
end
