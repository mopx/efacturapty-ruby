# Configuration

## Authentication

The gem supports two authentication modes — use whichever your efacturapty account provides.

### Option A: Static API token

If the API issued you a long-lived Bearer token, set `api_key`. No OAuth2 exchange is made;
the token is sent directly as the `Authorization: Bearer …` header on every request.

```ruby
Efacturapty.configure do |c|
  c.api_key = ENV["EFACTURAPTY_API_KEY"]
end
```

### Option B: OAuth2 client credentials

Exchanges `client_id` + `client_secret` for an access token via the IdentityServer.
The token is cached and automatically refreshed 60 seconds before expiry.

```ruby
Efacturapty.configure do |c|
  c.client_id     = ENV["EFACTURAPTY_CLIENT_ID"]
  c.client_secret = ENV["EFACTURAPTY_CLIENT_SECRET"]
end
```

## All options

```ruby
Efacturapty.configure do |c|
  # Authentication — choose one:
  c.api_key     = ENV["EFACTURAPTY_API_KEY"]      # Option A: static Bearer token
  c.client_id     = ENV["EFACTURAPTY_CLIENT_ID"]      # Option B: OAuth2 client id
  c.client_secret = ENV["EFACTURAPTY_CLIENT_SECRET"]  # Option B: OAuth2 client secret

  # Optional (shown with defaults)
  c.scope         = "apiApplication"     # OAuth2 scope (Option B only)
  c.api_base_url  = "https://api.efacturapty.com"
  c.auth_base_url = "https://sec.efacturapty.com"
  c.open_timeout  = 5                    # TCP connect timeout (seconds)
  c.read_timeout  = 30                   # Read timeout (seconds)
  c.logger        = nil                  # any Logger-compatible object
end
```

## Per-client configuration

Each `Efacturapty::Client.new(options)` call accepts the same keys:

```ruby
# Static token
client = Efacturapty::Client.new(api_key: "my-token")

# OAuth2
client = Efacturapty::Client.new(
  client_id:     "id",
  client_secret: "secret",
  logger:        Logger.new($stdout)
)
```

## Resetting in tests

```ruby
after { Efacturapty.reset! }
```

`reset!` clears the memoized global client and configuration, so the next call
to `Efacturapty.configure` / `Efacturapty.client` starts fresh.
