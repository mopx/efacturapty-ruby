Efacturapty.configure do |config|
  # Bearer token issued by your efacturapty account.
  config.api_key = ENV.fetch("EFACTURAPTY_API_KEY", nil)

  # HTTP timeouts in seconds.
  # config.open_timeout = 5
  # config.read_timeout = 30

  # Optional logger — e.g. Rails.logger to log all HTTP requests.
  # config.logger = Rails.logger
end
