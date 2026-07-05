# rubocop:disable RSpec/MultipleExpectations
RSpec.describe Efacturapty::Resources::Invoices do
  let(:client) { default_client }
  let(:invoice_payload) do
    { "datosGenerales" => { "tipoDocumento" => "01" } }
  end

  before { stub_token }

  describe "#create" do
    it "POSTs to /api/v1/Invoices with qr and xml query params" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .with(
               query: { "qr" => "true", "xml" => "true" },
               headers: { "Authorization" => "Bearer test-token" }
             )
             .to_return(
               status: 200,
               body: { "cufe" => "CUFE001", "autorizada" => true }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.create(invoice_payload, include_qr: true, include_xml: true, validate: false)
      expect(stub).to have_been_requested
    end

    it "defaults Accept-Language to es-PA and sends application/json-patch+json" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .with(headers: { "Accept-Language" => "es-PA", "Content-Type" => "application/json-patch+json" })
             .to_return(
               status: 200,
               body: { "cufe" => "CUFE001" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.create(invoice_payload, validate: false)
      expect(stub).to have_been_requested
    end

    it "returns a Response with cufe and autorizada" do
      stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
        .to_return(
          status: 200,
          body: { "cufe" => "CUFE001", "autorizada" => true }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      resp = client.invoices.create(invoice_payload, validate: false)
      expect(resp.cufe).to eq("CUFE001")
      expect(resp.autorizada).to be(true)
    end
  end

  describe "pre-flight validation" do
    it "raises ValidationError and never contacts the API for an invalid payload" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")

      expect { client.invoices.create(invoice_payload) }.to raise_error(Efacturapty::ValidationError) do |error|
        expect(error.errors).not_to be_empty
      end
      expect(stub).not_to have_been_requested
    end

    it "does not raise for a fully valid payload" do
      stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
        .to_return(
          status: 200,
          body: { "cufe" => "CUFE001" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect { client.invoices.create(valid_invoice_payload) }.not_to raise_error
    end

    it "skips validation when validate: false is passed" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .to_return(status: 200, body: {}.to_json, headers: { "Content-Type" => "application/json" })

      expect { client.invoices.create(invoice_payload, validate: false) }.not_to raise_error
      expect(stub).to have_been_requested
    end

    it "skips validation when config.validate_invoices is false" do
      client.config.validate_invoices = false
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .to_return(status: 200, body: {}.to_json, headers: { "Content-Type" => "application/json" })

      expect { client.invoices.create(invoice_payload) }.not_to raise_error
      expect(stub).to have_been_requested
    end
  end

  describe "#list" do
    it "GETs /api/v1/Invoices with camelized filter params" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices")
             .with(query: hash_including("DateFrom" => "2026-01-01", "PageSize" => "10"))
             .to_return(
               status: 200,
               body: { "items" => [] }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.list(date_from: "2026-01-01", page_size: 10)
      expect(stub).to have_been_requested
    end

    it "defaults Accept-Language to es-PA" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices")
             .with(headers: { "Accept-Language" => "es-PA" })
             .to_return(status: 200, body: { "data" => [] }.to_json, headers: { "Content-Type" => "application/json" })

      client.invoices.list
      expect(stub).to have_been_requested
    end

    it "does not forward filter keys the API does not support" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices")
             .with do |req|
               keys = URI.decode_www_form(req.uri.query || "").map(&:first)
               !keys.include?("Cufe") && !keys.include?("DocumentNumber")
             end
             .to_return(status: 200, body: { "data" => [] }.to_json, headers: { "Content-Type" => "application/json" })

      client.invoices.list(cufe: "should-be-ignored", document_number: "should-be-ignored")
      expect(stub).to have_been_requested
    end
  end

  describe "#find" do
    it "GETs /api/v1/Invoices/id/{cufeId} with Accept-Language" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/id/CUFE001")
             .with(headers: { "Accept-Language" => "es-PA" })
             .to_return(
               status: 200,
               body: { "id" => "CUFE001" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.find("CUFE001")
      expect(stub).to have_been_requested
    end
  end

  describe "#authorization" do
    it "GETs /api/v1/Invoices/Authorization/{cufe} with Accept-Language and returns the protocol" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/Authorization/CUFE001")
             .with(headers: { "Accept-Language" => "es-PA" })
             .to_return(
               status: 200,
               body: { "protocoloAutorizacion" => "PROT001" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      resp = client.invoices.authorization("CUFE001")
      expect(stub).to have_been_requested
      expect(resp["protocoloAutorizacion"]).to eq("PROT001")
    end

    it "forwards a custom locale" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/Authorization/CUFE001")
             .with(headers: { "Accept-Language" => "en" })
             .to_return(status: 200, body: {}.to_json, headers: { "Content-Type" => "application/json" })

      client.invoices.authorization("CUFE001", locale: "en")
      expect(stub).to have_been_requested
    end
  end

  describe "#cafe_file" do
    it "GETs the cafe-file binary endpoint with Accept-Language and returns raw bytes" do
      pdf_bytes = "%PDF-fake"
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/CUFE001/cafe-file")
             .with(headers: { "Accept-Language" => "es-PA" })
             .to_return(status: 200, body: pdf_bytes, headers: { "Content-Type" => "application/pdf" })

      result = client.invoices.cafe_file("CUFE001")
      expect(stub).to have_been_requested
      expect(result).to eq(pdf_bytes)
    end
  end

  describe "#create_credit_note" do
    it "POSTs with tipoDocumento 04 and documentosFiscalesReferenciados" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .with do |req|
               body = JSON.parse(req.body)
               dat  = body["datosGenerales"]
               dat["tipoDocumento"] == "04" &&
                 dat["documentosFiscalesReferenciados"].first.dig(
                   "informacionReferencia", "informacionReferencia", "cufeReferenciado"
                 ) == "CUFE-ORIG"
             end
             .to_return(
               status: 200,
               body: { "cufe" => "CUFE002", "autorizada" => true }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.create_credit_note(invoice_payload, referenced_cufe: "CUFE-ORIG",
                                                          referenced_date: "2026-06-01", validate: false)
      expect(stub).to have_been_requested
    end

    it "preserves existing datosGenerales fields" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .with do |req|
               dat = JSON.parse(req.body)["datosGenerales"]
               dat["ruc"] == "8-123-456" && dat["tipoDocumento"] == "04"
             end
             .to_return(
               status: 200,
               body: { "cufe" => "C" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      payload = { "datosGenerales" => { "ruc" => "8-123-456", "dv" => "01" } }
      client.invoices.create_credit_note(payload, referenced_cufe: "X", referenced_date: "2026-01-01", validate: false)
      expect(stub).to have_been_requested
    end
  end

  describe "#create_debit_note" do
    it "POSTs with tipoDocumento 05 and CUFE reference" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .with do |req|
               body = JSON.parse(req.body)
               body.dig("datosGenerales", "tipoDocumento") == "05"
             end
             .to_return(
               status: 200,
               body: { "cufe" => "CUFE003" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.create_debit_note(
        invoice_payload,
        referenced_cufe: "CUFE-ORIG",
        referenced_date: "2026-06-01",
        validate: false
      )
      expect(stub).to have_been_requested
    end
  end

  describe "#create_generic_credit_note" do
    it "POSTs with tipoDocumento 06 and no reference array" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .with do |req|
               body = JSON.parse(req.body)
               dat  = body["datosGenerales"]
               dat["tipoDocumento"] == "06" &&
                 !dat.key?("documentosFiscalesReferenciados")
             end
             .to_return(
               status: 200,
               body: { "cufe" => "CUFE004" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.create_generic_credit_note(invoice_payload, validate: false)
      expect(stub).to have_been_requested
    end
  end

  describe "#create_generic_debit_note" do
    it "POSTs with tipoDocumento 07 and no reference array" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
             .with do |req|
               body = JSON.parse(req.body)
               dat  = body["datosGenerales"]
               dat["tipoDocumento"] == "07" &&
                 !dat.key?("documentosFiscalesReferenciados")
             end
             .to_return(
               status: 200,
               body: { "cufe" => "CUFE005" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.create_generic_debit_note(invoice_payload, validate: false)
      expect(stub).to have_been_requested
    end
  end

  describe "#create_from_xml" do
    it "POSTs raw XML to CreateInvoiceFromXml with application/xml content-type" do
      xml = "<invoice><id>1</id></invoice>"
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices/CreateInvoiceFromXml")
             .with(body: xml, headers: { "Content-Type" => "application/xml" })
             .to_return(
               status: 200,
               body: { "cufe" => "CUFE001", "autorizada" => true }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.create_from_xml(xml)
      expect(stub).to have_been_requested
    end
  end

  describe "#authorization_admin" do
    it "GETs /api/v1/Invoices/AuthorizationAdmin/{cufe} and returns the protocol" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/AuthorizationAdmin/CUFE001")
             .to_return(
               status: 200,
               body: { "protocoloAutorizacion" => "PROT001" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      resp = client.invoices.authorization_admin("CUFE001")
      expect(stub).to have_been_requested
      expect(resp["protocoloAutorizacion"]).to eq("PROT001")
    end
  end

  describe "#qr_image" do
    it "GETs /api/v1/Invoices/GetQrImage/{cufe} and returns qr data" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/GetQrImage/CUFE001")
             .to_return(
               status: 200,
               body: { "qrImage" => "base64data==" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      resp = client.invoices.qr_image("CUFE001")
      expect(stub).to have_been_requested
      expect(resp["qrImage"]).to eq("base64data==")
    end
  end

  describe "#xml_from_dgi" do
    it "GETs /api/v1/Invoices/GetXmlFromDGI/{cufe} requesting XML and returns raw bytes" do
      xml_bytes = "<?xml version=\"1.0\"?><root/>"
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/GetXmlFromDGI/CUFE001")
             .with(headers: { "Accept" => "application/xml", "Accept-Language" => "es-PA" })
             .to_return(status: 200, body: xml_bytes, headers: { "Content-Type" => "application/xml" })

      result = client.invoices.xml_from_dgi("CUFE001")
      expect(stub).to have_been_requested
      expect(result).to eq(xml_bytes)
    end
  end

  describe "#taxpayer_response" do
    it "GETs /api/v1/Invoices/GetTaxpayerInvoiceResponse/{invoiceId}" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/GetTaxpayerInvoiceResponse/INV001")
             .to_return(
               status: 200,
               body: { "status" => "accepted" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      resp = client.invoices.taxpayer_response("INV001")
      expect(stub).to have_been_requested
      expect(resp["status"]).to eq("accepted")
    end
  end

  describe "#xml_file" do
    it "GETs /api/v1/Invoices/{cufeId}/xml-file and returns raw bytes" do
      xml_bytes = "<?xml version=\"1.0\"?><root/>"
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/CUFE001/xml-file")
             .to_return(status: 200, body: xml_bytes, headers: { "Content-Type" => "application/xml" })

      result = client.invoices.xml_file("CUFE001")
      expect(stub).to have_been_requested
      expect(result).to eq(xml_bytes)
    end
  end

  describe "#html_cafe" do
    it "GETs /api/v1/Invoices/{cufeId}/html-cafe and returns the html field" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/CUFE001/html-cafe")
             .to_return(
               status: 200,
               body: { "html" => "<div>cafe</div>" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      resp = client.invoices.html_cafe("CUFE001")
      expect(stub).to have_been_requested
      expect(resp["html"]).to eq("<div>cafe</div>")
    end

    it "forwards cafeFormat for thermal-printer output" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/CUFE001/html-cafe")
             .with(query: { "cafeFormat" => "eighty_mm" })
             .to_return(
               status: 200,
               body: { "html" => "<div/>" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.html_cafe("CUFE001", cafe_format: "eighty_mm")
      expect(stub).to have_been_requested
    end
  end

  describe "error handling" do
    it "raises NotFoundError on 404" do
      stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/id/MISSING")
        .to_return(
          status: 404,
          body: { "message" => "Not found" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect { client.invoices.find("MISSING") }.to raise_error(Efacturapty::NotFoundError)
    end

    it "raises ServerError on 500" do
      stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
        .to_return(
          status: 500,
          body: { "message" => "oops" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect { client.invoices.create(invoice_payload, validate: false) }.to raise_error(Efacturapty::ServerError)
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
