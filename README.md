# efacturapty

> **Disclaimer:** This gem is an independent, unofficial Ruby client library. It is **not**
> affiliated with, endorsed by, or supported by efacturapty or the Dirección General de Ingresos
> (DGI) of Panama. For official documentation and support, visit
> [efacturapty.com](https://www.efacturapty.com) and the
> [DGI e-factura portal](https://www.dgi.mef.gob.pa).

> **AI-generated code notice:** This library was generated with the assistance of AI tools.
> Review the source carefully before using it in production, and test against the sandbox
> environment before going live.

Ruby client gem for Panama's DGI **e-invoicing (e-factura / SFEP)** system, powered by the
[efacturapty](https://www.efacturapty.com) service.

Handles OAuth2 authentication, PAC authorization, invoice creation, cancellation, file downloads,
and all reference catalogs — compatible with **Ruby 2.6+ / Rails 5.2+** and modern stacks.

---

## Table of Contents

- [Installation](#installation)
- [Quick start](#quick-start)
- [Configuration](#configuration)
  - [Rails](#rails)
  - [Plain Ruby](#plain-ruby)
- [Authentication](#authentication)
- [Usage](#usage)
  - [Invoices](#invoices)
  - [Invoice Events (cancellation)](#invoice-events-cancellation)
  - [Catalogs](#catalogs)
- [Response objects](#response-objects)
- [Error handling](#error-handling)
- [Environments](#environments)
- [Development](#development)

---

## Installation

Add to your `Gemfile`:

```ruby
gem "efacturapty"
```

Or install directly:

```sh
gem install efacturapty
```

---

## Quick start

```ruby
require "efacturapty"

Efacturapty.configure do |c|
  c.client_id     = ENV["EFACTURAPTY_CLIENT_ID"]
  c.client_secret = ENV["EFACTURAPTY_CLIENT_SECRET"]
end

client = Efacturapty.client

# List countries catalog
countries = client.catalogs.countries

# Create and authorize an invoice
response = client.invoices.create(invoice_payload, qr: true)
puts response.cufe        # CUFE assigned by DGI
puts response.autorizada  # true when successfully authorized
```

---

## Configuration

### Rails

Run the install generator:

```sh
rails generate efacturapty:install
```

This creates `config/initializers/efacturapty.rb`:

```ruby
Efacturapty.configure do |config|
  config.client_id     = ENV.fetch("EFACTURAPTY_CLIENT_ID", nil)
  config.client_secret = ENV.fetch("EFACTURAPTY_CLIENT_SECRET", nil)

  # config.environment   = :production  # or :test
  # config.open_timeout  = 5
  # config.read_timeout  = 30
  # config.logger        = Rails.logger
end
```

### Plain Ruby

```ruby
require "efacturapty"

Efacturapty.configure do |c|
  c.client_id     = "your-client-id"
  c.client_secret = "your-client-secret"
end

client = Efacturapty.client
```

### Multiple clients

```ruby
client = Efacturapty::Client.new(
  client_id:     "id",
  client_secret: "secret",
  environment:   :production
)
```

### All configuration options

| Option | Default | Description |
|--------|---------|-------------|
| `client_id` | — | **Required.** OAuth2 client ID |
| `client_secret` | — | **Required.** OAuth2 client secret |
| `scope` | `"apiApplication"` | OAuth2 scope |
| `environment` | `:production` | `:production` or `:test` |
| `api_base_url` | `https://api.efacturapty.com` | Override API base URL |
| `auth_base_url` | `https://sec.efacturapty.com` | Override auth server URL |
| `open_timeout` | `5` | TCP connect timeout (seconds) |
| `read_timeout` | `30` | Read timeout (seconds) |
| `logger` | `nil` | Any Logger-compatible object |

---

## Authentication

The gem uses **OAuth2 `client_credentials`** flow against
`https://sec.efacturapty.com/connect/token`. Tokens are fetched automatically,
cached in memory, and refreshed 60 seconds before expiry. No manual token
management is required.

---

## Usage

### Invoices

#### Create and authorize an invoice

Accepts a plain Ruby Hash matching the DGI `InvoiceRequest` structure.
See [`docs/invoices.md`](docs/invoices.md) for the full payload schema.

```ruby
resp = client.invoices.create(
  {
    "datosGenerales" => {
      "tipoDocumento"   => "01",
      "naturalezaOperacion" => "01",
      # ...
    },
    "listaItems" => [ { ... } ],
    "totales"    => { ... }
  },
  qr:  true,   # include QR image (Base64) in response
  xml: true    # include raw authorized XML in response
)

resp.cufe               # => "CUFE-xxxx..."
resp.autorizada         # => true
resp.qr_content         # => "https://efacturapty.com/qr?cufe=..."
resp.qr_content_image_base64  # => "iVBORw0KGgo..."
resp.xml                # => "<?xml version=\"1.0\"...>"
```

#### Create from XML

```ruby
resp = client.invoices.create_from_xml(xml_string)
```

#### List invoices (paginated)

```ruby
page = client.invoices.list(
  date_from:    "2026-01-01",
  date_to:      "2026-06-30",
  status:       "Authorized",
  page:         1,
  page_size:    50
)
```

Available filter keys: `date_from`, `date_to`, `ruc`, `name`, `document_number`,
`billing_point`, `branch_office_code`, `status`, `document_type_codes`, `cufe`,
`environment`, `created_by`, `page`, `page_size`.

Pass `locale: "en"` to override the `Accept-Language` header.

#### Get invoice detail

```ruby
resp = client.invoices.find(cufe_id)
```

#### Authorization protocol + QR

```ruby
resp = client.invoices.authorization(cufe)
resp = client.invoices.authorization_admin(cufe)  # admin: any taxpayer
```

#### QR image

```ruby
resp = client.invoices.qr_image(cufe)  # Base64-encoded PNG
```

#### Files (binary downloads)

```ruby
pdf  = client.invoices.cafe_file(cufe_id)   # => binary PDF String
xml  = client.invoices.xml_file(cufe_id)    # => binary XML String
xml  = client.invoices.xml_from_dgi(cufe)   # => XML from DGI
html = client.invoices.html_cafe(cufe_id)   # => Response (HTML body)
```

#### Processing result

```ruby
resp = client.invoices.taxpayer_response(invoice_id)
```

#### Send by email

```ruby
client.invoices.mail_to(invoice_id)                       # to taxpayer default
client.invoices.mail_to(invoice_id, email: "x@y.com")    # override
```

---

### Invoice Events (cancellation)

```ruby
resp = client.invoice_events.cancel(
  cufe:   "CUFE-xxxx...",
  reason: "Error en los datos del receptor"
)
```

---

### Catalogs

```ruby
client.catalogs.countries       # list of countries
client.catalogs.currencies      # list of currencies
client.catalogs.locations       # districts / provinces / corregimientos
client.catalogs.cpbs_families   # CPBS product/service families
client.catalogs.cpbs_segments   # CPBS product/service segments
```

---

## Response objects

All non-binary endpoints return an `Efacturapty::Response` object.
Keys are accessible as methods or with `[]`:

```ruby
resp = client.catalogs.countries
resp["name"]   # hash-style
resp.name      # method-style
resp.to_h      # underlying Hash
resp.to_a      # underlying Array (for list responses)
resp.status    # HTTP status code
```

---

## Error handling

```ruby
begin
  client.invoices.create(payload)
rescue Efacturapty::AuthenticationError => e
  # 401 or bad credentials
  puts e.message
rescue Efacturapty::BadRequestError => e
  # 400 / 422
  puts e.body    # parsed response body
  puts e.status  # 400
rescue Efacturapty::NotFoundError
  # 404
rescue Efacturapty::RateLimitError
  # 429
rescue Efacturapty::ServerError
  # 5xx
rescue Efacturapty::ApiError => e
  # any other API error
rescue Efacturapty::ConfigurationError
  # missing credentials
rescue Efacturapty::Error => e
  # catch-all
end
```

### Error hierarchy

```
Efacturapty::Error
├── ConfigurationError
└── ApiError
    ├── AuthenticationError  (401)
    ├── BadRequestError      (400, 422)
    ├── NotFoundError        (404)
    ├── RateLimitError       (429)
    └── ServerError          (5xx)
```

---

## Environments

Set `config.environment = :test` to signal you are working in the sandbox.
This value is passed as the `Environment` filter on invoice listing. The API
base URL remains `https://api.efacturapty.com` — check with efacturapty support
for sandbox credentials.

---

## Development

```sh
git clone https://github.com/jorgeyau/efacturapty-ruby
cd efacturapty-ruby
bundle install

bundle exec rspec        # run tests
bundle exec rubocop      # lint
bin/console              # interactive console with gem loaded

gem build efacturapty.gemspec  # build .gem file
```

### Ruby version compatibility

Runtime requires **Ruby 2.6+**. Development tools (RuboCop, RSpec) run on
modern Ruby. Use a version manager (rbenv / rvm) to test on Ruby 2.6.10 with
`bundle exec rspec`.

---

## Contributing

Bug reports and pull requests welcome at
https://github.com/jorgeyau/efacturapty-ruby.

## License

MIT — see [LICENSE](LICENSE).
