require "spec_helper"

describe Codeplane::Resource::Base do
  subject(:resource) { described_class.new }

  it { expect(resource.errors).to be_an(Array) }

  describe "#attributes" do
    it "raises error" do
      expect {
        resource.attributes
      }.to raise_error(Codeplane::AbstractMethodError)
    end
  end

  describe "#valid?" do
    it "returns true" do
      expect(resource).to be_valid
    end

    it "return false" do
      resource.errors << "Something is wrong"
      expect(resource).not_to be_valid
    end
  end

  describe "#new_record?" do
    it "returns true" do
      resource = Codeplane::Resource::Thing.new
      expect(resource).to be_new_record
    end

    it "returns false" do
      resource = Codeplane::Resource::Thing.new(:id => 1234)
      expect(resource).not_to be_new_record
    end
  end

  context "coersion" do
    it "converts created_at stamps" do
      now = Time.now
      resource = Codeplane::Resource::Thing.new(:created_at => now.iso8601)
      expect(resource.created_at.to_s).to eq(now.to_s)
    end

    it "ignores empty created_at stamp" do
      expect {
        resource = Codeplane::Resource::Thing.new(:created_at => nil)
        expect(resource.created_at).to be_nil
      }.to_not raise_error
    end

    it "converts user" do
      resource = Codeplane::Resource::Thing.new(:user => {:name => "John Doe", :id => 1})
      expect(resource.user).to be_an(Codeplane::Resource::User)
      expect(resource.user.name).to eq("John Doe")
      expect(resource.user.id).to eq(1)
    end

    it "ignores empty user payload" do
      expect {
        resource = Codeplane::Resource::Thing.new(:user => nil)
        expect(resource.user).to be_nil
      }.to_not raise_error
    end
  end

  describe "#save" do
    before do
      default_credentials!
    end

    context "new resource" do
      subject(:resource) {
        Codeplane::Resource::Thing.new(:name => "tv", :collection_resource_path => "/things")
      }

      before do
        FakeWeb.register_uri :post, "https://john:abc@codeplane.com/api/v1/things",
          :status => 201, :body => fixtures.join("thing.json").read
        resource.save
      end

      it "makes a POST request" do
        expect(FakeWeb.last_request).to be_a(Net::HTTP::Post)
      end

      it "sets request body" do
        expect(request_body).to eq({"thing" => {"name" => "tv"}})
      end

      it "updates object" do
        expect(resource.id).to eq(1)
      end
    end

    context "existing resource" do
      subject(:resource) {
        Codeplane::Resource::Thing.new(:name => "tv", :collection_resource_path => "/things", :id => 1234)
      }

      before do
        FakeWeb.register_uri :put, "https://john:abc@codeplane.com/api/v1/things/1234",
          :status => 200, :body => fixtures.join("thing.json").read
        resource.save
      end

      it "makes a PUT request" do
        expect(FakeWeb.last_request).to be_a(Net::HTTP::Put)
      end

      it "sets request body" do
        expect(request_body).to eq({"thing" => {"name" => "tv"}})
      end
    end
  end

  describe "#save" do
    before do
      default_credentials!
    end

    context "new resource" do
      subject(:resource) {
        Codeplane::Resource::Thing.new(:name => "tv", :collection_resource_path => "/things")
      }

      it "raises error" do
        expect {
          resource.destroy
        }.to raise_error(Codeplane::UnsavedResourceError)
      end
    end

    context "existing resource" do
      subject(:resource) {
        Codeplane::Resource::Thing.new(:name => "tv", :collection_resource_path => "/things", :id => 1234)
      }

      before do
        FakeWeb.register_uri :delete, "https://john:abc@codeplane.com/api/v1/things/1234",
          :status => 200
        resource.destroy
      end

      it "makes a DELETE request" do
        expect(FakeWeb.last_request).to be_a(Net::HTTP::Delete)
      end
    end
  end
end
