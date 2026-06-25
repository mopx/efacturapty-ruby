RSpec.describe Efacturapty::Configuration do
  subject(:config) { described_class.new }

  describe "#validate!" do
    context "with OAuth2 credentials" do
      it "raises ConfigurationError when client_id is missing" do
        config.client_secret = "secret"
        expect { config.validate! }.to raise_error(Efacturapty::ConfigurationError, /client_id/)
      end

      it "raises ConfigurationError when client_secret is missing" do
        config.client_id = "id"
        expect { config.validate! }.to raise_error(Efacturapty::ConfigurationError, /client_secret/)
      end

      it "passes when both are set" do
        config.client_id     = "id"
        config.client_secret = "secret"
        expect { config.validate! }.not_to raise_error
      end
    end

    context "with a static api_key" do
      it "passes without client_id or client_secret" do
        config.api_key = "static-key"
        expect { config.validate! }.not_to raise_error
      end
    end
  end
end
