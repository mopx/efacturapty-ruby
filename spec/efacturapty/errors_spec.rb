# rubocop:disable RSpec/MultipleExpectations, RSpec/MultipleDescribes
RSpec.describe Efacturapty::ApiError do
  def fake_response(status, body)
    Struct.new(:status, :body).new(status, body)
  end

  describe ".from_response" do
    it "returns BadRequestError for 400 with correct status" do
      err = described_class.from_response(fake_response(400, { "message" => "bad" }))
      expect(err).to be_a(Efacturapty::BadRequestError)
      expect(err.status).to eq(400)
    end

    it "returns AuthenticationError for 401" do
      err = described_class.from_response(fake_response(401, {}))
      expect(err).to be_a(Efacturapty::AuthenticationError)
    end

    it "returns NotFoundError for 404" do
      err = described_class.from_response(fake_response(404, {}))
      expect(err).to be_a(Efacturapty::NotFoundError)
    end

    it "returns RateLimitError for 429" do
      err = described_class.from_response(fake_response(429, {}))
      expect(err).to be_a(Efacturapty::RateLimitError)
    end

    it "returns ServerError for 500 with message from body" do
      err = described_class.from_response(fake_response(500, { "message" => "oops" }))
      expect(err).to be_a(Efacturapty::ServerError)
      expect(err.message).to eq("oops")
    end

    it "uses title as message fallback" do
      err = described_class.from_response(fake_response(400, { "title" => "Validation error" }))
      expect(err.message).to eq("Validation error")
    end

    it "falls back to generic message" do
      err = described_class.from_response(fake_response(400, {}))
      expect(err.message).to include("API error (HTTP 400)")
    end
  end
end

RSpec.describe Efacturapty::ValidationError do
  it "is a plain Error, not an ApiError (no HTTP status/body involved)" do
    expect(described_class.ancestors).to include(Efacturapty::Error)
    expect(described_class.ancestors).not_to include(Efacturapty::ApiError)
  end

  it "exposes the collected errors and joins them into the message" do
    err = described_class.new(["listaItems is required", "totales is required"])
    expect(err.errors).to eq(["listaItems is required", "totales is required"])
    expect(err.message).to eq("Invoice payload is invalid: listaItems is required; totales is required")
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/MultipleDescribes
