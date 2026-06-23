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

      client.invoices.create(invoice_payload, include_qr: true, include_xml: true)
      expect(stub).to have_been_requested
    end

    it "returns a Response with cufe and autorizada" do
      stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices")
        .to_return(
          status: 200,
          body: { "cufe" => "CUFE001", "autorizada" => true }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      resp = client.invoices.create(invoice_payload)
      expect(resp.cufe).to eq("CUFE001")
      expect(resp.autorizada).to be(true)
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
  end

  describe "#find" do
    it "GETs /api/v1/Invoices/id/{cufeId}" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/id/CUFE001")
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
    it "GETs /api/v1/Invoices/Authorization/{cufe} and returns the protocol" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/Authorization/CUFE001")
             .to_return(
               status: 200,
               body: { "protocoloAutorizacion" => "PROT001" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      resp = client.invoices.authorization("CUFE001")
      expect(stub).to have_been_requested
      expect(resp["protocoloAutorizacion"]).to eq("PROT001")
    end
  end

  describe "#cafe_file" do
    it "GETs the cafe-file binary endpoint and returns raw bytes" do
      pdf_bytes = "%PDF-fake"
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Invoices/CUFE001/cafe-file")
             .to_return(status: 200, body: pdf_bytes, headers: { "Content-Type" => "application/pdf" })

      result = client.invoices.cafe_file("CUFE001")
      expect(stub).to have_been_requested
      expect(result).to eq(pdf_bytes)
    end
  end

  describe "#mail_to" do
    it "POSTs to /{invoiceId}/mailto" do
      stub = stub_request(:post, "https://api.efacturapty.com/api/v1/Invoices/INV001/mailto")
             .to_return(
               status: 200,
               body: {}.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoices.mail_to("INV001")
      expect(stub).to have_been_requested
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

      client.invoices.create_credit_note(
        invoice_payload,
        referenced_cufe: "CUFE-ORIG",
        referenced_date: "2026-06-01"
      )
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
      client.invoices.create_credit_note(payload, referenced_cufe: "X", referenced_date: "2026-01-01")
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
        referenced_date: "2026-06-01"
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

      client.invoices.create_generic_credit_note(invoice_payload)
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

      client.invoices.create_generic_debit_note(invoice_payload)
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

      expect { client.invoices.create(invoice_payload) }.to raise_error(Efacturapty::ServerError)
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
