require "spec_helper"

describe Codeplane::Resource::Repository, "#collaborators" do
  before do
    default_credentials!
  end

  let(:repository) { Codeplane::Resource::Repository.new(:id => 1234) }

  it "includes extension" do
    expect(repository.collaborators.singleton_class.included_modules).to include(Codeplane::Resource::Extensions::Collaborator)
  end

  it "does not respond to create" do
    expect(repository.collaborators).not_to respond_to(:create)
  end

  it "responds to invite" do
    expect(repository.collaborators).to respond_to(:invite)
  end

  it "responds to remove" do
    expect(repository.collaborators).to respond_to(:remove)
  end

  describe "#remove" do
    context "with existing collaborator" do
      before do
        FakeWeb.register_uri :get, "https://john:abc@codeplane.com/api/v1/repositories/some-project/collaborators", :body => [{:id => 5678, :email => "john@doe.com"}].to_json
        FakeWeb.register_uri :delete, "https://john:abc@codeplane.com/api/v1/repositories/some-project/collaborators/5678", :status => 200
      end

      let(:collaborators) {
        Codeplane::Resource::Repository.new(:name => "some-project").collaborators
      }

      it "makes a DELETE request" do
        collaborators.remove("john@doe.com")
        expect(FakeWeb.last_request).to be_a(Net::HTTP::Delete)
      end

      it "returns true" do
        expect(collaborators.remove("john@doe.com")).to be_truthy
      end
    end

    context "with missing collaborator" do
      before do
        FakeWeb.register_uri :get, "https://john:abc@codeplane.com/api/v1/repositories/some-project/collaborators", :body => [{:id => 5678, :email => "john@doe.com"}].to_json
        FakeWeb.register_uri :delete, "https://john:abc@codeplane.com/api/v1/repositories/some-project/collaborators/5678", :status => 404
      end

      let(:collaborators) {
        Codeplane::Resource::Repository.new(:name => "some-project").collaborators
      }

      it "raises exception" do
        expect { collaborators.remove("mary@doe.com") }.to raise_error(Codeplane::NotFoundError)
      end
    end
  end

  describe "#invite" do
    context "with valid data" do
      before do
        FakeWeb.register_uri :post, "https://john:abc@codeplane.com/api/v1/repositories/some-project/collaborators", :body => {:email => "john@doe.com", :errors => []}.to_json, :status => 201
      end

      let(:invitation) {
        Codeplane::Resource::Repository.new(:name => "some-project").collaborators.invite("john@doe.com")
      }

      it { expect(invitation.email).to eq("john@doe.com") }
      it { expect(invitation.errors).to be_an(Array) }

      it { expect(invitation).to be_valid }

      it "returns an invitation instance" do
        expect(invitation).to be_an(Codeplane::Resource::Invitation)
      end

      it "makes a POST request" do
        expect(FakeWeb.last_request).to be_a(Net::HTTP::Post)
        expect(request_body).to eq({"collaborator" => {"email" => "john@doe.com"}})
      end
    end

    context "with invalid data" do
      before do
        FakeWeb.register_uri :post, "https://john:abc@codeplane.com/api/v1/repositories/some-project/collaborators", :body => {:email => "john", :errors => ["Email is invalid"]}.to_json, :status => 201
      end

      let(:invitation) {
        Codeplane::Resource::Repository.new(:name => "some-project").collaborators.invite("john@doe.com")
      }

      it { expect(invitation).not_to be_valid }

      it "includes error messages" do
        expect(invitation.errors).to include("Email is invalid")
      end
    end
  end
end
