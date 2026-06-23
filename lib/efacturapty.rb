require_relative "efacturapty/version"
require_relative "efacturapty/errors"
require_relative "efacturapty/configuration"
require_relative "efacturapty/constants"
require_relative "efacturapty/client"

# Ruby client for Panama's DGI e-invoicing (e-factura / SFEP) system.
# @see https://github.com/mopx/efacturapty-ruby
module Efacturapty
  class << self
    # Global configuration instance.
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure the gem globally.
    #
    #   Efacturapty.configure do |config|
    #     config.client_id     = ENV["EFACTURAPTY_CLIENT_ID"]
    #     config.client_secret = ENV["EFACTURAPTY_CLIENT_SECRET"]
    #   end
    #
    def configure
      yield configuration
    end

    # A memoized default Client built from the global configuration.
    # Resets whenever {.reset!} is called.
    # @return [Client]
    def client
      @client ||= Client.new
    end

    # Reset the global configuration and memoized client.
    # Useful in test suites.
    def reset!
      @configuration = nil
      @client        = nil
    end
  end
end

require_relative "efacturapty/railtie" if defined?(Rails::Railtie)
