# Error Handling

## Error class hierarchy

```
Efacturapty::Error (inherits StandardError)
├── ConfigurationError     — missing/invalid config at startup
├── ValidationError        — client-side pre-flight check failed (no HTTP call made)
└── ApiError               — HTTP error from the API (has .status and .body)
    ├── AuthenticationError  — HTTP 401 (bad or expired api_key)
    ├── BadRequestError      — HTTP 400 / 422
    ├── NotFoundError        — HTTP 404
    ├── RateLimitError       — HTTP 429
    └── ServerError          — HTTP 5xx
```

## Rescuing errors

```ruby
begin
  resp = client.invoices.create(payload)
rescue Efacturapty::AuthenticationError => e
  # API returned 401 (bad or expired api_key)
  Rails.logger.error "efacturapty auth error: #{e.message}"
  raise
rescue Efacturapty::BadRequestError => e
  puts e.status  # 400
  puts e.body    # parsed JSON body, e.g. {"message"=>"Invalid tipoDocumento"}
rescue Efacturapty::NotFoundError
  # invoice not found
rescue Efacturapty::RateLimitError
  # back off and retry
rescue Efacturapty::ServerError => e
  Sentry.capture_exception(e)
rescue Efacturapty::ApiError => e
  # catch-all for unexpected API status codes
  puts "#{e.status}: #{e.message}"
end
```

## ApiError attributes

| Attribute | Description |
|-----------|-------------|
| `message` | Human-readable error message (extracted from response body) |
| `status`  | HTTP status code (Integer) |
| `body`    | Parsed response body (Hash or nil) |

## ConfigurationError

Raised synchronously during `Client.new` or `Efacturapty.client` if `api_key` is blank.

## ValidationError

Raised by `Efacturapty::InvoiceValidator` (used internally by `Invoices#create` and the
credit/debit note helpers) when an invoice payload fails client-side pre-flight checks. Unlike
`ApiError` and its subclasses, this is **not** an HTTP error — it has no `.status` or `.body`,
because the request is never sent. It carries `.errors`, an Array of every violation found (the
validator collects all problems rather than stopping at the first):

```ruby
begin
  client.invoices.create(payload)
rescue Efacturapty::ValidationError => e
  e.errors   # => ["listaItems is required and must be a non-empty array", ...]
  e.message  # => "Invoice payload is invalid: listaItems is required and must be a non-empty array; ..."
end
```

See [`docs/invoices.md`](invoices.md#client-side-validation) for what is and isn't checked, and
[`docs/configuration.md`](configuration.md#validate_invoices) for how to disable it.

## AuthenticationError

Raised only when the API itself returns HTTP 401 (a bad or expired `api_key`) — the gem sends
`api_key` directly as the Bearer token on every request, so there is no separate token-exchange
step that can fail.
