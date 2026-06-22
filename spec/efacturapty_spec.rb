RSpec.describe Efacturapty do
  describe ".VERSION" do
    it "is defined and non-nil" do
      expect(Efacturapty::VERSION).not_to be_nil
    end
  end

  describe ".configure / .configuration" do
    it "yields the configuration object" do
      described_class.configure do |c|
        c.client_id     = "my-id"
        c.client_secret = "my-secret"
      end
      expect(described_class.configuration.client_id).to eq("my-id")
    end

    # rubocop:disable RSpec/MultipleExpectations
    it "uses defaults for unset values" do
      cfg = described_class.configuration
      expect(cfg.api_base_url).to  eq(Efacturapty::Configuration::API_BASE_URL)
      expect(cfg.auth_base_url).to eq(Efacturapty::Configuration::AUTH_BASE_URL)
      expect(cfg.scope).to         eq(Efacturapty::Configuration::DEFAULT_SCOPE)
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe ".client" do
    it "returns a Client built from global config" do
      stub_token
      described_class.configure do |c|
        c.client_id     = "id"
        c.client_secret = "secret"
      end
      expect(described_class.client).to be_a(Efacturapty::Client)
    end
  end

  describe ".reset!" do
    it "clears the memoized client and configuration" do
      described_class.configure { |c| c.client_id = "x" }
      described_class.reset!
      expect(described_class.configuration.client_id).to be_nil
    end
  end
end
