require "webmock/rspec"
require "efacturapty"

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    Efacturapty.reset!
  end
end

# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------
def default_client
  Efacturapty::Client.new(api_key: "test-key")
end

# A minimal InvoiceRequest payload that satisfies every InvoiceValidator rule.
# Use this (instead of a bare-bones fixture) wherever a spec needs a payload
# that is expected to pass client-side pre-flight validation.
def valid_invoice_payload
  {
    "datosGenerales" => {
      "tipoDocumento" => "01",
      "informacionReceptor" => { "tipoContribuyente" => "01" }
    },
    "listaItems" => [valid_invoice_item],
    "totales" => valid_invoice_totales
  }
end

def valid_invoice_totales
  {
    "tiempoPago" => 1,
    "grupoFormasPago" => [{ "formaPago" => "02", "valorCuotaPagada" => 10.7 }],
    "valorTotalFactura" => 10.7
  }
end

def valid_invoice_item
  {
    "numeroSecuenciaItem" => 1,
    "descripcionProductoServicio" => "Producto A",
    "cantidadProductoServicio" => 1,
    "grupoPrecios" => { "precioItem" => 10.0 },
    "grupoITBMS" => { "tasaITBMSAplicable" => "01", "montoITBMS" => 0.7 }
  }
end
