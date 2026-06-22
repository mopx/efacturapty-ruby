require "webmock/rspec"
require "efacturapty"

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    Efacturapty.reset!
  end
end

# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------
def stub_token
  stub_request(:post, "https://sec.efacturapty.com/connect/token")
    .to_return(
      status: 200,
      body: { "access_token" => "test-token", "expires_in" => 3600 }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
end

def default_client
  Efacturapty::Client.new(
    client_id: "test-id",
    client_secret: "test-secret"
  )
end
