require "spec_helper"

describe Codeplane do
  describe ".configure" do
    it "sets username" do
      Codeplane.configure {|c| c.username = "johndoe"}
      expect(Codeplane.username).to eq("johndoe")
    end

    it "sets API key" do
      Codeplane.configure {|c| c.api_key = "abc"}
      expect(Codeplane.api_key).to eq("abc")
    end
  end

  describe ".endpoint" do
    it "returns real url" do
      ENV.delete("CODEPLANE_ENDPOINT")
      expect(Codeplane.endpoint).to eq("https://codeplane.com/api/v1")
    end

    it "returns alternative url" do
      ENV["CODEPLANE_ENDPOINT"] = "http://example.com"
      expect(Codeplane.endpoint).to eq("http://example.com")
    end
  end
end
