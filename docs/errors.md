# Error Handling

## Error class hierarchy

```
Efacturapty::Error (inherits StandardError)
├── ConfigurationError     — missing/invalid config at startup
└── ApiError               — HTTP error from the API (has .status and .body)
    ├── AuthenticationError  — HTTP 401, or bad OAuth2 credentials
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
  # OAuth2 token fetch failed, or API returned 401
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

Raised synchronously during `Client.new` or `Efacturapty.client` if
`client_id` or `client_secret` are blank.

## AuthenticationError (token failures)

Raised by the `Token` class when the OAuth2 token endpoint returns a non-200
response. The message includes the HTTP status code and response body.
