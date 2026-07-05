RSpec.describe Efacturapty::Resources::Taxpayers do
  let(:client) { default_client }
  let(:taxpayer_response) do
    { "ruc" => "8-888-8888", "dv" => "5", "name" => "Acme Corp", "isRegisteredDgi" => true }.to_json
  end

  describe "#query_ruc" do
    it "GETs the correct path with taxpayer_type and ruc" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Taxpayers/QueryRucDvPac/1/8-888-8888")
             .with(headers: { "Authorization" => "Bearer test-key" })
             .to_return(status: 200, body: taxpayer_response, headers: { "Content-Type" => "application/json" })

      client.taxpayers.query_ruc("8-888-8888", taxpayer_type: 1)
      expect(stub).to have_been_requested
    end

    it "works with taxpayer_type 2" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Taxpayers/QueryRucDvPac/2/NT-8888888")
             .to_return(status: 200, body: taxpayer_response, headers: { "Content-Type" => "application/json" })

      client.taxpayers.query_ruc("NT-8888888", taxpayer_type: 2)
      expect(stub).to have_been_requested
    end

    it "returns a Response with the taxpayer name" do
      stub_request(:get, "https://api.efacturapty.com/api/v1/Taxpayers/QueryRucDvPac/1/8-888-8888")
        .to_return(status: 200, body: taxpayer_response, headers: { "Content-Type" => "application/json" })

      expect(client.taxpayers.query_ruc("8-888-8888", taxpayer_type: 1).name).to eq("Acme Corp")
    end

    it "returns a Response with dv and isRegisteredDgi" do
      stub_request(:get, "https://api.efacturapty.com/api/v1/Taxpayers/QueryRucDvPac/1/8-888-8888")
        .to_return(status: 200, body: taxpayer_response, headers: { "Content-Type" => "application/json" })

      response = client.taxpayers.query_ruc("8-888-8888", taxpayer_type: 1)
      expect(response.dv).to eq("5")
    end
  end
end
