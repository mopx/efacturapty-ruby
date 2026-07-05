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
    constants.rb                  # DGI code tables (document types, operation natures, etc.)
    invoice_validator.rb          # pre-flight validation for Invoices#create payloads
    token.rb                      # OAuth2 client_credentials via Net::HTTP (thread-safe)
    connection.rb                 # Faraday wrapper: JSON, auth header, retry, binary GETs,
                                   # default Accept + Content-Type (application/json-patch+json)
    response.rb                   # thin Response wrapper (method_missing → hash keys)
    client.rb                     # Client: holds config+token, exposes resource accessors
    railtie.rb                    # Rails::Railtie (loads generators)
    resources/
      base_resource.rb            # get/post/get_raw helpers, compact(nil removal)
      invoices.rb                 # 12 Invoices endpoints
      invoice_events.rb           # cancel (CreateCancellation)
      catalogs.rb                 # countries, currencies, locations, cpbs_families, cpbs_segments
      subscriptions.rb            # list (paginated)
      taxpayers.rb                # query_ruc (QueryRucDvPac)
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
    invoice_validator_spec.rb
    token_spec.rb
    resources/
      invoices_spec.rb
      invoice_events_spec.rb
      catalogs_spec.rb
      subscriptions_spec.rb
      taxpayers_spec.rb

docs/
  getting-started.md
  invoices.md                     # DGI InvoiceRequest payload schema + response fields
  configuration.md
  errors.md
  catalogs.md
  subscriptions.md                # subscription fields + list usage
  taxpayers.md                    # query_ruc usage + response fields
```

## API facts (live OpenAPI spec at https://api.efacturapty.com/swagger/v1/swagger.json)

Official per-endpoint reference docs (Stoplight-generated PDFs, more authoritative than the raw
OpenAPI spec for header/param behavior) live in `efacturapty-docs/` at the repo root — read them
before changing request/response shapes for an endpoint they cover.

- **Base URL:** `https://api.efacturapty.com`
- **`Accept-Language` is required on every documented Invoices endpoint**; the API's own default
  is `es-PA` (not bare `es`). All resource methods default their `locale:` kwarg to `"es-PA"`.
- **POST bodies use `Content-Type: application/json-patch+json`**, not `application/json` — set
  automatically by `Connection#post` for Hash/Array bodies.
- **Auth:** Two modes supported:
  - Static API key (`config.api_key`): Bearer token sent directly, no OAuth2 call.
  - OAuth2 `client_credentials` (`config.client_id` + `client_secret`) →
    `https://sec.efacturapty.com/connect/token`. Scope: `apiApplication`.
    Token is cached + auto-refreshed (60s buffer before expiry).
- **17 endpoints** in three groups:

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
  | InvoiceEvents | POST | `/api/v1/InvoiceEvents/CreateCancellation` |
  | Catalogs | GET | `/api/v1/Catalogs/countries` |
  | Catalogs | GET | `/api/v1/Catalogs/currencies` |
  | Catalogs | GET | `/api/v1/Catalogs/locations` |
  | Catalogs | GET | `/api/v1/Catalogs/CPBSfams` |
  | Catalogs | GET | `/api/v1/Catalogs/CPBSsegs` |
  | Subscriptions | GET | `/api/v1/Subscriptions` |
  | Taxpayers | GET | `/api/v1/Taxpayers/QueryRucDvPac/{taxpayerType}/{ruc}` |

## Error hierarchy

```
Efacturapty::Error
├── ConfigurationError
├── ValidationError  (has .errors — client-side only, no HTTP status/body)
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
- **Pre-flight validation, kept deliberately thin.** `Invoices#create` (and the credit/debit
  note helpers built on it) run `InvoiceValidator` before the HTTP call and raise
  `ValidationError` on failure — pass `validate: false` per call or set
  `config.validate_invoices = false` globally to skip it (default `true`). The validator is
  permissive by design: it only checks presence/enums/formats the docs make unambiguous and
  that the API can't default (see `docs/invoices.md#client-side-validation`); it deliberately
  does NOT attempt deep full-schema validation of every nested DTO, since that would drift from
  the live API and risk rejecting valid payloads — leave cross-field math and business rules to
  the API itself.
- **Binary endpoints** (`cafe_file`, `xml_file`, `xml_from_dgi`) return raw String bytes,
  not Response objects — use `get_raw` in Connection.
- `xml_from_dgi` always sends `Accept: application/xml`; without it the API returns JSON
  (`events` + `xmlRaw`) instead of the raw XML the method name promises.
- **`compact`** in BaseResource strips nil query params before sending.
- **`list` filters**: only `date_from`, `date_to`, `ruc`, `name`, `page`, `page_size`, `status`,
  and `environment` (API-deprecated) are real query params — `PARAM_MAP` in invoices.rb
  camelizes and whitelists them; anything else is silently dropped rather than sent as a
  meaningless lowercase query param. Include `locale:` key in the filters hash to set
  `Accept-Language` (default `"es-PA"`).
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
