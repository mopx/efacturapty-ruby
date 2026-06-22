# Configuration

## All options

```ruby
Efacturapty.configure do |c|
  # Required
  c.client_id     = ENV["EFACTURAPTY_CLIENT_ID"]
  c.client_secret = ENV["EFACTURAPTY_CLIENT_SECRET"]

  # Optional (shown with defaults)
  c.scope         = "apiApplication"
  c.environment   = :production          # :production or :test
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
