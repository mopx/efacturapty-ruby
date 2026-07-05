# rubocop:disable RSpec/MultipleExpectations
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
               body: { "id" => "evt1" }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      client.invoice_events.cancel(cufe: "abc123", reason: "Error en datos")
      expect(stub).to have_been_requested
    end

    it "returns a Response with the cancellation id" do
      stub_request(:post, "https://api.efacturapty.com/api/v1/InvoiceEvents/CreateCancellation")
        .to_return(
          status: 200,
          body: { "id" => "evt1" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = client.invoice_events.cancel(cufe: "abc123")
      expect(result).to be_a(Efacturapty::Response)
      expect(result["id"]).to eq("evt1")
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
