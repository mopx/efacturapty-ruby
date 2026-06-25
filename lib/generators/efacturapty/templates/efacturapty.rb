Efacturapty.configure do |config|
  # Authentication — choose one:
  #
  # Option A: static API key (Bearer token used directly — no OAuth2 exchange).
  # config.api_key = ENV.fetch("EFACTURAPTY_API_KEY", nil)
  #
  # Option B: OAuth2 client credentials (exchanges client_id+secret for an access_token).
  config.client_id     = ENV.fetch("EFACTURAPTY_CLIENT_ID", nil)
  config.client_secret = ENV.fetch("EFACTURAPTY_CLIENT_SECRET", nil)

  # Scope granted to this client (only used with Option B, default "apiApplication").
  # config.scope = "apiApplication"

  # Environment: :production (default) or :test.
  # config.environment = :production

  # HTTP timeouts in seconds.
  # config.open_timeout = 5
  # config.read_timeout = 30

  # Optional logger — e.g. Rails.logger to log all HTTP requests.
  # config.logger = Rails.logger
end
