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

Log in to your [efacturapty](https://www.efacturapty.com) account. The gem supports two
authentication modes — use whichever your account provides (see
[`docs/configuration.md`](configuration.md) for details on both):

- **Option A — static API key** (recommended if issued): a long-lived Bearer token.
  ```sh
  export EFACTURAPTY_API_KEY="your-api-key"
  ```
- **Option B — OAuth2 client credentials**: a Client ID and Client Secret.
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

**Plain Ruby (Option A — api_key):**

```ruby
require "efacturapty"

Efacturapty.configure do |c|
  c.api_key = ENV["EFACTURAPTY_API_KEY"]
end
```

**Plain Ruby (Option B — OAuth2):**

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
      "tipoDocumento"       => "01",  # Factura de operación interna
      "naturalezaOperacion" => "01",  # Venta
      "tipoOperacion"       => 1,     # Salida o venta
      "destinoOperacion"    => 1,     # Panamá
      "fechaEmision"        => Time.now.strftime("%Y-%m-%dT%H:%M:%S%:z"),
      "informacionReceptor" => {
        "tipoContribuyente" => "02",  # Consumidor final
        "numeroRUC"         => "8-123-4567",
        "razonSocial"       => "Cliente de Prueba"
      }
    },
    "listaItems" => [
      {
        "numeroSecuenciaItem"         => 1,
        "descripcionProductoServicio" => "Consulting service",
        "cantidadProductoServicio"    => 1,
        "grupoPrecios" => {
          "precioUnitarioTransferencia" => 500.00,
          "precioItem"                  => 500.00,
          "sumaPrecioItem"              => 500.00
        },
        "grupoITBMS" => {
          "tasaITBMSAplicable" => "01",  # 7%
          "montoITBMS"         => 35.00
        }
      }
    ],
    "totales" => {
      "tiempoPago"      => 1,  # Contado
      "grupoFormasPago" => [
        { "formaPago" => "02", "valorCuotaPagada" => 535.00 }
      ],
      "valorTotalFactura" => 535.00
    }
  },
  include_qr: true
)

puts "CUFE: #{response.cufe}"
puts "Authorized: #{response.autorizada}"
```

See [`docs/invoices.md`](invoices.md) for the full `InvoiceRequest` field reference — this
example only shows the fields required to pass client-side validation, not every optional field.

## Next steps

- [`docs/invoices.md`](invoices.md) — full payload schema + response fields
- [`docs/errors.md`](errors.md) — error handling
- [`docs/configuration.md`](configuration.md) — all config options
- [`docs/catalogs.md`](catalogs.md) — reference data
