RSpec.describe Efacturapty::Configuration do
  subject(:config) { described_class.new }

  describe "#validate_invoices" do
    it "defaults to true" do
      expect(config.validate_invoices).to be(true)
    end

    it "can be disabled" do
      config.validate_invoices = false
      expect(config.validate_invoices).to be(false)
    end
  end

  describe "#validate!" do
    it "raises ConfigurationError when api_key is missing" do
      expect { config.validate! }.to raise_error(Efacturapty::ConfigurationError, /api_key/)
    end

    it "passes when api_key is set" do
      config.api_key = "static-key"
      expect { config.validate! }.not_to raise_error
    end
  end
end
