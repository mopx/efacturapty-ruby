# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed
- **Breaking:** OAuth2 `client_credentials` authentication. `Token`, and
  `Configuration#client_id`/`#client_secret`/`#scope`/`#auth_base_url`, have been removed.
  `api_key` is now the only supported authentication mode — set it directly and it's sent as
  the `Authorization: Bearer` header on every request, with no token exchange or refresh.

### Added
- `Efacturapty::Constants` module with all DGI reference code tables from Ficha Técnica v1.10:
  `DOCUMENT_TYPES`, `OPERATION_NATURES`, `OPERATION_DIRECTIONS`, `DESTINATIONS`,
  `CAFE_FORMATS`, `CAFE_DELIVERY_METHODS`, `CONTAINER_DELIVERY`, `GENERATION_PROCESSES`,
  `SALE_TRANSACTION_TYPES`, `RECEPTOR_TYPES`, `ITBMS_RATES`, `PAYMENT_METHODS`
- Invoice document-type helpers on `Resources::Invoices`:
  - `create_credit_note(payload, referenced_cufe:, referenced_date:, **opts)` — tipoDocumento "04"
  - `create_debit_note(payload, referenced_cufe:, referenced_date:, **opts)` — tipoDocumento "05"
  - `create_generic_credit_note(payload, **opts)` — tipoDocumento "06"
  - `create_generic_debit_note(payload, **opts)` — tipoDocumento "07"
- Docs: `docs/constants.md`, extended `docs/invoices.md` with credit/debit note section

### Planned
- Typed request builders for DGI invoice DTOs (gEmis, gItem, gTot, etc.)
- WebPos API endpoints

## [0.1.0] - 2026-06-22

### Added
- OAuth2 `client_credentials` token management with auto-refresh (`Token`)
- `Configuration` class with all API options and `validate!`
- `Connection` via Faraday 1/2 with JSON middleware, retry, and binary download support
- `Response` wrapper exposing JSON keys as methods
- `Efacturapty::Client` with `.invoices`, `.invoice_events`, `.catalogs` accessors
- `Resources::Invoices` — 13 endpoints (create, create_from_xml, list, find, authorization,
  qr_image, xml_from_dgi, taxpayer_response, cafe_file, xml_file, html_cafe, mail_to)
- `Resources::InvoiceEvents` — cancel (CreateCancellation)
- `Resources::Catalogs` — countries, currencies, locations, cpbs_families, cpbs_segments
- Full error hierarchy: `ApiError`, `AuthenticationError`, `BadRequestError`,
  `NotFoundError`, `RateLimitError`, `ServerError`, `ConfigurationError`
- Rails Railtie + `efacturapty:install` generator
- 34-example WebMock-stubbed RSpec suite, 0 failures
- Docs: README, getting-started, invoices, configuration, errors, catalogs
- CLAUDE.md with architecture map and API reference
- Compatible with **Ruby 2.6+** / **Rails 5.2+**
