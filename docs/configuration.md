# Configuration

## Authentication

Set `api_key` to the Bearer token issued by your efacturapty account. No token exchange is
made; the key is sent directly as the `Authorization: Bearer …` header on every request.

```ruby
Efacturapty.configure do |c|
  c.api_key = ENV["EFACTURAPTY_API_KEY"]
end
```

## All options

```ruby
Efacturapty.configure do |c|
  c.api_key           = ENV["EFACTURAPTY_API_KEY"]  # Required.
  c.api_base_url      = "https://api.efacturapty.com"
  c.open_timeout      = 5                 # TCP connect timeout (seconds)
  c.read_timeout      = 30                # Read timeout (seconds)
  c.logger            = nil               # any Logger-compatible object
  c.validate_invoices = true              # client-side pre-flight validation on Invoices#create
end
```

### `validate_invoices`

When `true` (the default), `client.invoices.create` (and the credit/debit note helpers built on
top of it) run `Efacturapty::InvoiceValidator` against the payload before making any HTTP request,
raising `Efacturapty::ValidationError` if it fails — this avoids wasting a slow PAC round-trip on
a request that's missing a required field or has an invalid enum value. Set it to `false` to
disable this globally, or pass `validate: false` to a single `create` call to bypass it just for
that call. See [`docs/invoices.md`](invoices.md#client-side-validation) and
[`docs/errors.md`](errors.md) for details.

## Per-client configuration

Each `Efacturapty::Client.new(options)` call accepts the same keys:

```ruby
client = Efacturapty::Client.new(
  api_key: "my-token",
  logger:  Logger.new($stdout)
)
```

## Resetting in tests

```ruby
after { Efacturapty.reset! }
```

`reset!` clears the memoized global client and configuration, so the next call
to `Efacturapty.configure` / `Efacturapty.client` starts fresh.
