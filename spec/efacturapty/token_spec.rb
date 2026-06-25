RSpec.describe Efacturapty::Token do
  subject(:token) { described_class.new(config) }

  let(:config) do
    cfg = Efacturapty::Configuration.new
    cfg.client_id     = "test-id"
    cfg.client_secret = "test-secret"
    cfg
  end

  describe "#access_token" do
    context "when api_key is configured" do
      subject(:t) do
        cfg = Efacturapty::Configuration.new
        cfg.api_key = "static-key-abc"
        described_class.new(cfg)
      end

      it "returns the static token" do
        expect(t.access_token).to eq("static-key-abc")
      end

      it "makes no network call" do
        t.access_token
        expect(a_request(:post, "https://sec.efacturapty.com/connect/token")).not_to have_been_made
      end
    end

    it "returns the token from the token endpoint" do
      stub_request(:post, "https://sec.efacturapty.com/connect/token")
        .with(body: hash_including("grant_type" => "client_credentials"))
        .to_return(
          status: 200,
          body: { "access_token" => "abc123", "expires_in" => 3600 }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect(token.access_token).to eq("abc123")
    end

    it "caches the token and only calls the endpoint once" do
      stub = stub_request(:post, "https://sec.efacturapty.com/connect/token")
             .to_return(
               status: 200,
               body: { "access_token" => "abc123", "expires_in" => 3600 }.to_json,
               headers: { "Content-Type" => "application/json" }
             )

      2.times { token.access_token }
      expect(stub).to have_been_requested.once
    end

    it "raises AuthenticationError on 401" do
      stub_request(:post, "https://sec.efacturapty.com/connect/token")
        .to_return(status: 401, body: "Unauthorized")

      expect { token.access_token }.to raise_error(Efacturapty::AuthenticationError)
    end
  end
end
