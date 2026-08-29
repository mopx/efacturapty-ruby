# rubocop:disable-next RSpec/MultipleExpectations
RSpec.describe Efacturapty::Resources::InvoiceEvents do
  let(:client) { default_client }

  describe "#cancel" do
    it "POSTs to CreateCancellation with cufe and reason" do
      url  = "https://api.efacturapty.com/api/v1/InvoiceEvents/CreateCancellation"
      stub = stub_request(:post, url)
             .with(
               body: { "cufe" => "abc123", "cancellationReason" => "Error en datos" }.to_json,
               headers: { "Authorization" => "Bearer test-key" }
             )
             .to_return(
               status: 200,
               body: [{ "codigo" => "0", "mensaje" => "Evento registrado con éxito" }].to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoice_events.cancel(cufe: "abc123", reason: "Error en datos")
      expect(stub).to have_been_requested
    end

    it "returns a Response wrapping the codigo/mensaje array" do
      stub_request(:post, "https://api.efacturapty.com/api/v1/InvoiceEvents/CreateCancellation")
        .to_return(
          status: 200,
          body: [{ "codigo" => "0", "mensaje" => "Evento registrado con éxito" }].to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = client.invoice_events.cancel(cufe: "abc123", reason: "Error en datos")
      expect(result).to be_a(Efacturapty::Response)
      expect(result.to_a.first["mensaje"]).to eq("Evento registrado con éxito")
    end

    it "requires a reason" do
      expect { client.invoice_events.cancel(cufe: "abc123") }.to raise_error(ArgumentError, /reason/)
    end
  end

  describe "#events" do
    it "GETs GetAll/{cufe} with default locale and no eventType when omitted" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/InvoiceEvents/GetAll/CUFE001")
             .with(headers: { "Accept-Language" => "es-PA" })
             .to_return(
               status: 200,
               body: { "events" => [{ "eventCode" => 1, "invoiceEventType" => "authorization" }] }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoice_events.events("CUFE001")
      expect(stub).to have_been_requested
    end

    it "does not send an eventType query param when omitted" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/InvoiceEvents/GetAll/CUFE001")
             .with do |req|
               !URI.decode_www_form(req.uri.query || "").map(&:first).include?("eventType")
             end
             .to_return(status: 200, body: { "events" => [] }.to_json,
                        headers: { "Content-Type" => "application/json" })

      client.invoice_events.events("CUFE001")
      expect(stub).to have_been_requested
    end

    it "sends eventType when provided" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/InvoiceEvents/GetAll/CUFE001")
             .with(query: { "eventType" => "cancellation" })
             .to_return(status: 200, body: { "events" => [] }.to_json,
                        headers: { "Content-Type" => "application/json" })

      client.invoice_events.events("CUFE001", event_type: "cancellation")
      expect(stub).to have_been_requested
    end

    it "returns a Response with the events array" do
      stub_request(:get, "https://api.efacturapty.com/api/v1/InvoiceEvents/GetAll/CUFE001")
        .to_return(
          status: 200,
          body: { "events" => [{ "eventCode" => 1, "invoiceEventType" => "authorization" }] }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = client.invoice_events.events("CUFE001")
      expect(result.events.first["invoiceEventType"]).to eq("authorization")
    end
  end
end
