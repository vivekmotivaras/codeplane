require "spec_helper"

describe Codeplane::Request do
  context "request shortcuts" do
    it "implements GET" do
      expect(subject).to respond_to(:get)
    end

    it "implements POST" do
      expect(subject).to respond_to(:post)
    end

    it "implements PUT" do
      expect(subject).to respond_to(:put)
    end

    it "implements DELETE" do
      expect(subject).to respond_to(:delete)
    end
  end

  describe "#net_class" do
    it "detects GET" do
      expect(subject.net_class(:Get)).to eq(Net::HTTP::Get)
    end

    it "detects POST" do
      expect(subject.net_class(:Post)).to eq(Net::HTTP::Post)
    end

    it "detects PUT" do
      expect(subject.net_class(:Put)).to eq(Net::HTTP::Put)
    end

    it "detects DELETE" do
      expect(subject.net_class(:Delete)).to eq(Net::HTTP::Delete)
    end
  end

  describe "#request" do
    before do
      ENV["CODEPLANE_ENDPOINT"] = "https://example.com"
      FakeWeb.register_uri :any, "https://example.com", :status => 200
    end

    it "sets request as HTTPS" do
      subject.get("/")
      request = FakeWeb.last_request
    end

    it "sets user agent" do
      subject.get("/")
      expect(FakeWeb.last_request["User-Agent"]).to eq("Codeplane/#{Codeplane::Version::STRING}")
    end

    it "sets content type" do
      subject.get("/")
      expect(FakeWeb.last_request["Content-Type"]).to eq("application/x-www-form-urlencoded")
    end

    it "sets body" do
      subject.post("/", :repository => {:name => "myrepo"})
      expect(request_body).to eq({"repository" => {"name" => "myrepo"}})
    end

    it "sets credentials" do
      Codeplane.configure do |config|
        config.username = "john"
        config.api_key = "abc"
      end

      FakeWeb.register_uri :any, "https://john:abc@example.com", :status => 200
      subject.get("/")
      expect(FakeWeb.last_request["authorization"]).to eq("Basic " + Base64.encode64("john:abc").chomp)
    end

    it "returns a response object" do
      expect(subject.get("/")).to be_a(Codeplane::Response)
    end

    it "detects 401 status" do
      FakeWeb.register_uri :any, "https://example.com", :status => 401

      expect {
        subject.get("/")
      }.to raise_error(Codeplane::UnauthorizedError)
    end


    it "detects 404 status" do
      FakeWeb.register_uri :any, "https://example.com", :status => 404

      expect {
        subject.get("/")
      }.to raise_error(Codeplane::NotFoundError)
    end
  end
end
