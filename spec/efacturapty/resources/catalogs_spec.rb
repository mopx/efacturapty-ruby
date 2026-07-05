RSpec.describe Efacturapty::Resources::Catalogs do
  let(:client) { default_client }

  shared_examples "a catalog endpoint" do |method, path|
    it "GETs #{path}" do
      stub = stub_request(:get, "https://api.efacturapty.com#{path}")
             .with(headers: { "Authorization" => "Bearer test-key" })
             .to_return(status: 200, body: [].to_json, headers: { "Content-Type" => "application/json" })

      client.catalogs.public_send(method)
      expect(stub).to have_been_requested
    end
  end

  it_behaves_like "a catalog endpoint", :countries,       "/api/v1/Catalogs/countries"
  it_behaves_like "a catalog endpoint", :currencies,      "/api/v1/Catalogs/currencies"
  it_behaves_like "a catalog endpoint", :locations,       "/api/v1/Catalogs/locations"
  it_behaves_like "a catalog endpoint", :cpbs_families,   "/api/v1/Catalogs/CPBSfams"
  it_behaves_like "a catalog endpoint", :cpbs_segments,   "/api/v1/Catalogs/CPBSsegs"
end
