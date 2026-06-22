# Invoices

## Creating an invoice

`client.invoices.create(payload, qr: false, xml: false, locale: "es")`

The `payload` is a plain Ruby Hash that maps 1:1 to the DGI `InvoiceRequest` JSON structure.
The gem forwards it directly to the API — no validation is performed at the Ruby layer.

### Top-level InvoiceRequest keys

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `datosGenerales` | Hash | Yes | General invoice data (`GDGenRequest`) |
| `listaItems` | Array of Hashes | Yes | Line items (`GItemRequest`) |
| `totales` | Hash | Yes | Invoice totals (`GTotRequest`) |
| `detallePedido` | Hash | No | Purchase order detail |
| `informacionLogistica` | Hash | No | Logistics info |
| `datosLocal` | Hash | No | Commercial establishment data |
| `cufe` | String | No | CUFE (set only when correcting) |

### datosGenerales (GDGenRequest) — most-used fields

```ruby
"datosGenerales" => {
  "tipoDocumento"       => "01",          # 01=FE, 02=FE corrective, 03=receipt, …
  "naturalezaOperacion" => "01",          # 01=interior sale
  "tipoOperacion"       => "1",           # 1=sale
  "destinoOperacion"    => "1",           # 1=domestic
  "formatoCAFE"         => "1",           # 1=PDF, 2=PDF+XML
  "entregaNetCAFE"       => "1",
  "envioContenedor"      => "1",
  "proceso"              => "1",          # 1=normal
  "tipoVenta"            => "1",          # 1=contado
  "fechaEmision"         => "2026-06-22", # YYYY-MM-DD
  "fechaSalida"          => "2026-06-22",
  "datosEmisor"          => { ... },      # GRucEmiRequest (RUC, DV, name, address)
  "datosReceptor"        => { ... }       # GRucRecRequest (customer data)
}
```

### listaItems — line item

```ruby
{
  "descripcion"   => "Producto X",
  "cantidad"      => 1,
  "precioUnitario"=> 100.00,
  "precioItem"    => 100.00,
  "valorTotal"    => 107.00,
  "tasaITBMS"     => "01",               # 01=7%, 02=10%, 03=15%, 00=0%
  "montoITBMS"    => 7.00,
  "codigoUnidadMedida" => "EA",
  "codigoCPBS"    => "44121700"
}
```

### totales (GTotRequest)

```ruby
"totales" => {
  "totalPrecioNeto"  => 100.00,
  "totalITBMS"       => 7.00,
  "totalMontoGravado"=> 100.00,
  "totalFactura"     => 107.00,
  "totalValorRecibido" => 107.00,
  "vuelto"           => 0.00,
  "tiempoPago"       => "1"              # 1=immediate
}
```

## CreateInvoiceResponse fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Internal invoice ID |
| `cufe` | String | Código Único de Factura Electrónica |
| `secuence` | Integer | Sequential number |
| `autorizada` | Boolean | True when DGI/PAC authorization succeeded |
| `fechaAutorizacion` | String | ISO-8601 authorization timestamp |
| `protocoloAutorizacion` | String | Authorization protocol string |
| `qrContent` | String | URL encoded in the QR code |
| `qrContentImageBase64` | String | Base64 PNG of the QR image |
| `xml` | String | Raw authorized XML (only if `xml: true` requested) |
| `invoice` | String | Serialized invoice |
| `rRetEnviFe` | Hash | Full PAC protocol response |
| `isRetry` | Boolean | Whether this was a retry |

## Listing invoices

```ruby
client.invoices.list(
  date_from:            "2026-01-01",  # DateFrom
  date_to:              "2026-12-31",  # DateTo
  ruc:                  "8-123-4567",
  status:               "Authorized",
  document_type_codes:  ["01"],        # Array
  cufe:                 "CUFE...",
  page:                 1,
  page_size:            50,
  locale:               "es"           # Accept-Language
)
```

Returns a paginated response. The response body matches `IPaginated<InvoiceDocumentResponse>`.
