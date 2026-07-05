# Catalogs

Reference data endpoints. All return an `Efacturapty::Response` wrapping a
JSON array.

```ruby
catalog = client.catalogs

# Countries (used for GIdExtRequest / foreign IDs)
catalog.countries
# => [{"code"=>"PA", "name"=>"Panama"}, ...]

# Currencies (ISO-4217 codes used in invoice)
catalog.currencies
# => [{"code"=>"USD", "name"=>"US Dollar"}, ...]

# Locations: distritos, provincias, corregimientos
catalog.locations

# CPBS (Catalog of Products and Services) — family level
catalog.cpbs_families

# CPBS — segment level (more granular)
catalog.cpbs_segments
```

Use catalog values to populate invoice fields such as (see [`docs/invoices.md`](invoices.md) for
the full `InvoiceRequest` schema these belong to):
- `datosGenerales.informacionEmisor` location fields — from `locations`
- `listaItems[n].codigoItemCodificacionPanamena` / `codigoItemCodificacionPanamenaAbreviada` —
  from `cpbs_families` / `cpbs_segments`
- `datosGenerales.facturaExportacion` (required when `destinoOperacion` is `2`) — from `countries`,
  for foreign customers
