RSpec.describe Efacturapty do
  describe ".VERSION" do
    it "is defined and non-nil" do
      expect(Efacturapty::VERSION).not_to be_nil
    end
  end

  describe ".configure / .configuration" do
    it "yields the configuration object" do
      described_class.configure { |c| c.api_key = "my-key" }
      expect(described_class.configuration.api_key).to eq("my-key")
    end

    it "uses defaults for unset values" do
      cfg = described_class.configuration
      expect(cfg.api_base_url).to eq(Efacturapty::Configuration::API_BASE_URL)
    end
  end

  describe ".client" do
    it "returns a Client built from global config" do
      described_class.configure { |c| c.api_key = "my-key" }
      expect(described_class.client).to be_a(Efacturapty::Client)
    end
  end

  describe ".reset!" do
    it "clears the memoized client and configuration" do
      described_class.configure { |c| c.api_key = "x" }
      described_class.reset!
      expect(described_class.configuration.api_key).to be_nil
    end
  end
end
