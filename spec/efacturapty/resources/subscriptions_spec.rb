RSpec.describe Efacturapty::Resources::Subscriptions do
  let(:client) { default_client }
  let(:paginated_response) do
    {
      "currentPage" => 1, "pageCount" => 1, "pageSize" => 10,
      "rowCount" => 1, "firstRowOnPage" => 1, "lastRowOnPage" => 1,
      "data" => [
        {
          "id" => "sub-1", "userId" => "u-1", "ruc" => "8-888-888",
          "taxpayerName" => "Acme Corp", "subscriptionNumber" => "S-001",
          "transactions" => 100, "availableTransactions" => 75,
          "status" => "Active", "validFrom" => "2025-01-01", "validUntil" => "2026-01-01",
          "planName" => "Pro", "planType" => "Monthly",
          "partnerUserId" => "p-1", "percentageConsumed" => 25,
          "unlimited" => false, "branchOfficeCode" => "001"
        }
      ]
    }.to_json
  end

  describe "#list" do
    it "GETs /api/v1/Subscriptions with default locale" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Subscriptions")
             .with(
               headers: {
                 "Authorization" => "Bearer test-key",
                 "Accept-Language" => "es-PA"
               }
             )
             .to_return(status: 200, body: paginated_response, headers: { "Content-Type" => "application/json" })

      client.subscriptions.list
      expect(stub).to have_been_requested
    end

    it "sends Page and PageSize when provided" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Subscriptions")
             .with(query: { "Page" => "2", "PageSize" => "5" })
             .to_return(status: 200, body: paginated_response, headers: { "Content-Type" => "application/json" })

      client.subscriptions.list(page: 2, page_size: 5)
      expect(stub).to have_been_requested
    end

    it "omits Page and PageSize when not provided" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Subscriptions")
             .with(query: {})
             .to_return(status: 200, body: paginated_response, headers: { "Content-Type" => "application/json" })

      client.subscriptions.list
      expect(stub).to have_been_requested
    end

    it "accepts a custom locale" do
      stub = stub_request(:get, "https://api.efacturapty.com/api/v1/Subscriptions")
             .with(headers: { "Accept-Language" => "en" })
             .to_return(status: 200, body: paginated_response, headers: { "Content-Type" => "application/json" })

      client.subscriptions.list(locale: "en")
      expect(stub).to have_been_requested
    end

    it "returns a Response whose data is an Array" do
      stub_request(:get, "https://api.efacturapty.com/api/v1/Subscriptions")
        .to_return(status: 200, body: paginated_response, headers: { "Content-Type" => "application/json" })

      expect(client.subscriptions.list.data).to be_an(Array)
    end

    it "returns subscription fields in data" do
      stub_request(:get, "https://api.efacturapty.com/api/v1/Subscriptions")
        .to_return(status: 200, body: paginated_response, headers: { "Content-Type" => "application/json" })

      expect(client.subscriptions.list.data.first["subscriptionNumber"]).to eq("S-001")
    end
  end
end
