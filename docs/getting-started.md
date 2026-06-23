# Getting Started

> **Unofficial library:** This gem is not affiliated with or supported by efacturapty or the DGI.
> For official API documentation visit [efacturapty.com](https://www.efacturapty.com).
>
> **AI-generated code:** This library was built with AI assistance. Review and test thoroughly
> before deploying to production.

## 1. Install the gem

```ruby
# Gemfile
gem "efacturapty"
```

```sh
bundle install
```

## 2. Get credentials

Log in to your [efacturapty](https://www.efacturapty.com) account and create
an API client. Note the **Client ID** and **Client Secret**.

Set them as environment variables:

```sh
export EFACTURAPTY_CLIENT_ID="your-client-id"
export EFACTURAPTY_CLIENT_SECRET="your-client-secret"
```

## 3. Configure

**Rails** — run the generator:

```sh
rails generate efacturapty:install
```

Then edit `config/initializers/efacturapty.rb`.

**Plain Ruby:**

```ruby
require "efacturapty"

Efacturapty.configure do |c|
  c.client_id     = ENV["EFACTURAPTY_CLIENT_ID"]
  c.client_secret = ENV["EFACTURAPTY_CLIENT_SECRET"]
end
```

## 4. Make your first call

```ruby
client = Efacturapty.client

# Verify connectivity
countries = client.catalogs.countries
puts countries.to_a.first
```

## 5. Issue an invoice

```ruby
response = client.invoices.create(
  {
    "datosGenerales" => {
      "tipoDocumento"       => "01",
      "naturalezaOperacion" => "01",
      "tipoOperacion"       => "1",
      "destinoOperacion"    => "1",
      "formatoCAFE"         => "1",
      "entregaNetCAFE"       => "1",
      "envioContenedor"      => "1",
      "proceso"              => "1",
      "tipoVenta"            => "1",
      "fechaEmision"         => Date.today.iso8601,
      "fechaSalida"          => Date.today.iso8601,
      "datosEmisor"          => { ... },
      "datosReceptor"        => { ... }
    },
    "listaItems" => [
      {
        "descripcion"    => "Consulting service",
        "cantidad"       => 1,
        "precioUnitario" => 500.00,
        "precioItem"     => 500.00,
        "valorTotal"     => 535.00,
        "tasaITBMS"      => "01",
        "montoITBMS"     => 35.00
      }
    ],
    "totales" => {
      "totalPrecioNeto"   => 500.00,
      "totalITBMS"        => 35.00,
      "totalMontoGravado" => 500.00,
      "totalFactura"      => 535.00,
      "totalValorRecibido"=> 535.00,
      "vuelto"            => 0.00,
      "tiempoPago"        => "1"
    }
  },
  qr: true
)

puts "CUFE: #{response.cufe}"
puts "Authorized: #{response.autorizada}"
```

## Next steps

- [`docs/invoices.md`](invoices.md) — full payload schema + response fields
- [`docs/errors.md`](errors.md) — error handling
- [`docs/configuration.md`](configuration.md) — all config options
- [`docs/catalogs.md`](catalogs.md) — reference data
