Efacturapty.configure do |config|
  # OAuth2 client credentials — get these from your efacturapty account.
  config.client_id     = ENV.fetch("EFACTURAPTY_CLIENT_ID", nil)
  config.client_secret = ENV.fetch("EFACTURAPTY_CLIENT_SECRET", nil)

  # Scope granted to this client (default "apiApplication").
  # config.scope = "apiApplication"

  # Environment: :production (default) or :test.
  # config.environment = :production

  # HTTP timeouts in seconds.
  # config.open_timeout = 5
  # config.read_timeout = 30

  # Optional logger — e.g. Rails.logger to log all HTTP requests.
  # config.logger = Rails.logger
end
