RSpec.describe Efacturapty::Connection do
  let(:taxpayer_response) do
    { "ruc" => "8-888-8888", "dv" => "5", "name" => "Acme Corp", "isRegisteredDgi" => true }.to_json
  end

  # Regression: a real request logged `Authorization: "Bearer <real api_key>"`
  # in full to an application's log, since Faraday's :logger middleware logs
  # request headers verbatim by default with no filtering configured.
  describe "logging the Authorization header" do
    let(:logged) { StringIO.new }
    let(:logger) { Logger.new(logged) }
    let(:client) { Efacturapty::Client.new(api_key: "super-secret-key", logger: logger) }

    before do
      stub_request(:get, "https://api.efacturapty.com/api/v1/Taxpayers/QueryRucDvPac/1/8-888-8888")
        .to_return(status: 200, body: taxpayer_response, headers: { "Content-Type" => "application/json" })
    end

    it "never writes the real api_key to the logger" do
      client.taxpayers.query_ruc("8-888-8888", taxpayer_type: 1)

      expect(logged.string).not_to include("super-secret-key")
    end

    it "redacts the Authorization header while keeping the log line recognizable" do
      client.taxpayers.query_ruc("8-888-8888", taxpayer_type: 1)

      expect(logged.string).to include('Authorization: "Bearer [REDACTED]"')
    end

    it "still logs the request method and URL" do
      client.taxpayers.query_ruc("8-888-8888", taxpayer_type: 1)

      expect(logged.string).to include("GET https://api.efacturapty.com")
    end
  end

  it "does not attach the :logger middleware at all when no logger is configured" do
    stub_request(:get, "https://api.efacturapty.com/api/v1/Taxpayers/QueryRucDvPac/1/8-888-8888")
      .to_return(status: 200, body: taxpayer_response, headers: { "Content-Type" => "application/json" })

    expect { default_client.taxpayers.query_ruc("8-888-8888", taxpayer_type: 1) }.not_to raise_error
  end
end
