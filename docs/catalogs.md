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

Use catalog values to populate invoice fields such as:
- `datosGenerales.datosEmisor.gUbiEm.distrito` — from locations
- `listaItems[n].codigoCPBS` — from cpbs_families / cpbs_segments
- `datosReceptor.gIdExt.pais` — from countries (for foreign customers)
