# rubocop:disable-next RSpec/MultipleExpectations
RSpec.describe Efacturapty::InvoiceValidator do
  let(:payload) { valid_invoice_payload }

  describe ".errors_for" do
    it "returns no errors for a fully valid payload" do
      expect(described_class.errors_for(payload)).to eq([])
    end

    it "returns an error for a non-Hash / empty payload without raising" do
      expect(described_class.errors_for(nil)).to include(a_string_matching(/non-empty Hash/))
      expect(described_class.errors_for({})).to include(a_string_matching(/non-empty Hash/))
    end

    it "requires datosGenerales" do
      payload.delete("datosGenerales")
      expect(described_class.errors_for(payload)).to include(a_string_matching(/datosGenerales is required/))
    end

    it "requires totales" do
      payload.delete("totales")
      expect(described_class.errors_for(payload)).to include(a_string_matching(/totales is required/))
    end

    it "requires a non-empty listaItems array" do
      payload["listaItems"] = []
      expect(described_class.errors_for(payload)).to include(a_string_matching(/listaItems is required/))
    end

    it "flags a non-Hash item in listaItems" do
      payload["listaItems"] = ["not a hash"]
      expect(described_class.errors_for(payload)).to include("listaItems[0] must be an object")
    end

    it "requires informacionReceptor inside datosGenerales" do
      payload["datosGenerales"].delete("informacionReceptor")
      errors = described_class.errors_for(payload)
      expect(errors).to include(a_string_matching(/informacionReceptor is required/))
    end

    describe "enum fields on datosGenerales" do
      %w[tipoEmision tipoDocumento naturalezaOperacion tipoOperacion destinoOperacion
         tipoTransaccionVenta tipoSucursal].each do |field|
        it "rejects an invalid #{field}" do
          payload["datosGenerales"][field] = "not-a-real-code"
          errors = described_class.errors_for(payload)
          expect(errors).to include(a_string_matching(/#{field} must be one of/))
        end
      end

      it "accepts an integer or string enum value equivalently" do
        payload["datosGenerales"]["tipoOperacion"] = 1
        expect(described_class.errors_for(payload)).to eq([])

        payload["datosGenerales"]["tipoOperacion"] = "1"
        expect(described_class.errors_for(payload)).to eq([])
      end
    end

    describe "puntoFacturacion" do
      it "rejects \"000\"" do
        payload["datosGenerales"]["puntoFacturacion"] = "000"
        expect(described_class.errors_for(payload)).to include(a_string_matching(/puntoFacturacion/))
      end

      it "rejects a value that is not exactly 3 digits" do
        payload["datosGenerales"]["puntoFacturacion"] = "1"
        expect(described_class.errors_for(payload)).to include(a_string_matching(/puntoFacturacion/))
      end

      it "accepts a valid 3-digit value" do
        payload["datosGenerales"]["puntoFacturacion"] = "001"
        expect(described_class.errors_for(payload)).to eq([])
      end
    end

    describe "facturaExportacion" do
      it "is required when destinoOperacion is 2" do
        payload["datosGenerales"]["destinoOperacion"] = 2
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/facturaExportacion is required/))
      end

      it "is satisfied once facturaExportacion is present" do
        payload["datosGenerales"]["destinoOperacion"] = 2
        payload["datosGenerales"]["facturaExportacion"] = { "paisDestino" => "US" }
        expect(described_class.errors_for(payload)).to eq([])
      end
    end

    describe "documentosFiscalesReferenciados" do
      it "is required when tipoDocumento is 04 or 05" do
        payload["datosGenerales"]["tipoDocumento"] = "04"
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/documentosFiscalesReferenciados is required/))
      end

      it "is satisfied once the reference array is present" do
        payload["datosGenerales"]["tipoDocumento"] = "04"
        payload["datosGenerales"]["documentosFiscalesReferenciados"] = [{ "fechaEmisionDocumentoReferenciado" => "x" }]
        expect(described_class.errors_for(payload)).to eq([])
      end
    end

    describe "listaItems fields" do
      %w[numeroSecuenciaItem descripcionProductoServicio cantidadProductoServicio grupoPrecios
         grupoITBMS].each do |field|
        it "requires #{field} on each item" do
          payload["listaItems"].first.delete(field)
          errors = described_class.errors_for(payload)
          expect(errors).to include(a_string_matching(/listaItems\[0\]\.#{field} is required/))
        end
      end

      it "rejects numeroSecuenciaItem outside 1..9999" do
        payload["listaItems"].first["numeroSecuenciaItem"] = 10_000
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/numeroSecuenciaItem must be an integer between 1 and 9999/))
      end

      it "rejects a descripcionProductoServicio shorter than 2 characters" do
        payload["listaItems"].first["descripcionProductoServicio"] = "A"
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/descripcionProductoServicio must be 2-500 characters/))
      end

      it "rejects an invalid grupoITBMS.tasaITBMSAplicable" do
        payload["listaItems"].first["grupoITBMS"]["tasaITBMSAplicable"] = "99"
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/tasaITBMSAplicable must be one of/))
      end
    end

    describe "totales fields" do
      it "requires tiempoPago" do
        payload["totales"].delete("tiempoPago")
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/tiempoPago is required/))
      end

      it "rejects an invalid tiempoPago" do
        payload["totales"]["tiempoPago"] = 9
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/tiempoPago must be one of/))
      end

      it "requires a non-empty grupoFormasPago" do
        payload["totales"]["grupoFormasPago"] = []
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/grupoFormasPago is required/))
      end

      it "requires grupoInformacionPago when tiempoPago is 2 or 3" do
        payload["totales"]["tiempoPago"] = 2
        errors = described_class.errors_for(payload)
        expect(errors).to include(a_string_matching(/grupoInformacionPago is required/))
      end

      it "is satisfied once grupoInformacionPago is present" do
        payload["totales"]["tiempoPago"] = 2
        payload["totales"]["grupoInformacionPago"] = [{ "montoAPagar" => 10.7 }]
        expect(described_class.errors_for(payload)).to eq([])
      end
    end

    it "aggregates every violation instead of stopping at the first" do
      payload["datosGenerales"].delete("informacionReceptor")
      payload["listaItems"] = []
      payload["totales"].delete("tiempoPago")

      errors = described_class.errors_for(payload)
      expect(errors.size).to be >= 3
    end

    it "tolerates symbol keys" do
      symbol_payload = {
        datosGenerales: { tipoDocumento: "01", informacionReceptor: { tipoContribuyente: "01" } },
        listaItems: [
          {
            numeroSecuenciaItem: 1,
            descripcionProductoServicio: "Producto A",
            cantidadProductoServicio: 1,
            grupoPrecios: { precioItem: 10.0 },
            grupoITBMS: { tasaITBMSAplicable: "01" }
          }
        ],
        totales: { tiempoPago: 1, grupoFormasPago: [{ formaPago: "02" }] }
      }
      expect(described_class.errors_for(symbol_payload)).to eq([])
    end
  end

  describe ".validate!" do
    it "does not raise for a valid payload" do
      expect { described_class.validate!(payload) }.not_to raise_error
    end

    it "raises a ValidationError carrying the collected errors" do
      expect { described_class.validate!({}) }.to raise_error(Efacturapty::ValidationError) do |error|
        expect(error.errors).not_to be_empty
        expect(error.message).to include("Invoice payload is invalid")
      end
    end
  end
end
