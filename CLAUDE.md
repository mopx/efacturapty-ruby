# efacturapty

Ruby gem wrapping Panama's **efacturapty** service — the DGI e-invoicing (e-factura / SFEP) API.

## Purpose

Makes it easy to integrate the efacturapty REST API into any Ruby 2.6+ or Rails 5.2+ app.
Handles OAuth2 auth, PAC authorization, invoice CRUD, cancellation, file downloads, and catalogs.

## Architecture

```
lib/
  efacturapty.rb                  # top-level module: configure, client, reset!
  efacturapty/
    version.rb                    # VERSION constant
    errors.rb                     # full error hierarchy (see below)
    configuration.rb              # all knobs, defaults, validate!
    token.rb                      # OAuth2 client_credentials via Net::HTTP (thread-safe)
    connection.rb                 # Faraday wrapper: JSON, auth header, retry, binary GETs
    response.rb                   # thin Response wrapper (method_missing → hash keys)
    client.rb                     # Client: holds config+token, exposes resource accessors
    railtie.rb                    # Rails::Railtie (loads generators)
    resources/
      base_resource.rb            # get/post/get_raw helpers, compact(nil removal)
      invoices.rb                 # 13 Invoices endpoints
      invoice_events.rb           # cancel (CreateCancellation)
      catalogs.rb                 # countries, currencies, locations, cpbs_families, cpbs_segments
      subscriptions.rb            # list (paginated)
  generators/
    efacturapty/
      install_generator.rb        # rails g efacturapty:install
      templates/efacturapty.rb    # initializer template

spec/
  spec_helper.rb                  # WebMock setup, stub_token helper, default_client helper
  efacturapty_spec.rb             # module-level configure/client/reset!
  efacturapty/
    configuration_spec.rb
    errors_spec.rb
    token_spec.rb
    resources/
      invoices_spec.rb
      invoice_events_spec.rb
      catalogs_spec.rb
      subscriptions_spec.rb

docs/
  getting-started.md
  invoices.md                     # DGI InvoiceRequest payload schema + response fields
  configuration.md
  errors.md
  catalogs.md
  subscriptions.md                # subscription fields + list usage
```

## API facts (live OpenAPI spec at https://api.efacturapty.com/swagger/v1/swagger.json)

- **Base URL:** `https://api.efacturapty.com`
- **Auth:** OAuth2 `client_credentials` → `https://sec.efacturapty.com/connect/token`
  Scope: `apiApplication`. Token is cached + auto-refreshed (60s buffer before expiry).
- **18 endpoints** in three groups:

  | Group | Method | Path |
  |-------|--------|------|
  | Invoices | POST | `/api/v1/Invoices` |
  | Invoices | GET | `/api/v1/Invoices` |
  | Invoices | POST | `/api/v1/Invoices/CreateInvoiceFromXml` |
  | Invoices | GET | `/api/v1/Invoices/Authorization/{cufe}` |
  | Invoices | GET | `/api/v1/Invoices/AuthorizationAdmin/{cufe}` |
  | Invoices | GET | `/api/v1/Invoices/GetQrImage/{cufe}` |
  | Invoices | GET | `/api/v1/Invoices/GetXmlFromDGI/{cufe}` |
  | Invoices | GET | `/api/v1/Invoices/GetTaxpayerInvoiceResponse/{invoiceId}` |
  | Invoices | GET | `/api/v1/Invoices/id/{cufeId}` |
  | Invoices | GET | `/api/v1/Invoices/{cufeId}/cafe-file` |
  | Invoices | GET | `/api/v1/Invoices/{cufeId}/xml-file` |
  | Invoices | GET | `/api/v1/Invoices/{cufeId}/html-cafe` |
  | Invoices | POST | `/api/v1/Invoices/{invoiceId}/mailto` |
  | InvoiceEvents | POST | `/api/v1/InvoiceEvents/CreateCancellation` |
  | Catalogs | GET | `/api/v1/Catalogs/countries` |
  | Catalogs | GET | `/api/v1/Catalogs/currencies` |
  | Catalogs | GET | `/api/v1/Catalogs/locations` |
  | Catalogs | GET | `/api/v1/Catalogs/CPBSfams` |
  | Catalogs | GET | `/api/v1/Catalogs/CPBSsegs` |
  | Subscriptions | GET | `/api/v1/Subscriptions` |

## Error hierarchy

```
Efacturapty::Error
├── ConfigurationError
└── ApiError  (has .status, .body)
    ├── AuthenticationError  (401 + token failures)
    ├── BadRequestError      (400/422)
    ├── NotFoundError        (404)
    ├── RateLimitError       (429)
    └── ServerError          (5xx)
```

`ApiError.from_response(faraday_response)` maps HTTP status → subclass.

## Key conventions

- **Invoice payloads are pass-through hashes.** No typed request builders exist yet.
  The gem forwards the hash directly as JSON. Future work: typed builder objects
  for the ~50 nested DGI DTOs (gEmis, gItem, gTot, etc.).
- **Binary endpoints** (`cafe_file`, `xml_file`, `xml_from_dgi`) return raw String bytes,
  not Response objects — use `get_raw` in Connection.
- **`compact`** in BaseResource strips nil query params before sending.
- **`list` filters** are snake_case symbols; `PARAM_MAP` in invoices.rb camelizes them.
  Include `locale:` key in the filters hash to set `Accept-Language`.
- `Connection#post` only sends the request body when it's non-nil and non-empty.

## Compatibility

- Runtime: **Ruby >= 2.6** (no 2.7+/3.0-only syntax used in lib/).
- `faraday >= 1.0, < 3` and `faraday-retry >= 1.0, < 3` (works across Faraday 1.x and 2.x).
- Rails: 5.2+ (Railtie + generator APIs used are stable back to 5.2).
- Dev tooling (RuboCop, RSpec) runs on modern Ruby only.

## Commands

```sh
bundle exec rspec                       # run all tests
bundle exec rspec spec/efacturapty/...  # specific spec
bundle exec rubocop                     # lint (TargetRubyVersion 2.6)
gem build efacturapty.gemspec           # build .gem artifact
bin/console                             # irb with gem loaded
```

## Working rules

- **When adding or changing a resource**, always update: the spec file for that resource, the architecture tree and endpoint table in this file, and the relevant doc in `docs/`.
- **When adding a new resource**, also create `docs/<resource>.md` documenting the endpoint(s), parameters, and response fields.

## Testing approach

All HTTP calls are stubbed with WebMock — no live network calls.
`stub_token` (in spec_helper) stubs the OAuth2 token endpoint.
`default_client` creates `Client.new(client_id: "test-id", client_secret: "test-secret")`.

Call `Efacturapty.reset!` in `after` blocks to clear global state between tests.
