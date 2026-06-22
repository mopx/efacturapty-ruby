# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
