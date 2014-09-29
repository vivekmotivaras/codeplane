require "spec_helper"

describe Codeplane::Resource::Repository do
  subject(:repository) {
    Codeplane::Resource::Repository.new(
      :id => 1234,
      :name => "some-project",
      :collection_resource_path => "/repositories"
    )
  }

  describe "#collaborators" do
    let(:collection) { :collaborators }
    let(:resource_path) { "/repositories/some-project/collaborators" }
    let(:resource_class_name) { "User" }
    let(:resource_class) { Codeplane::Resource::User }

    it_behaves_like "resource collection"
  end

  describe "#resource_path" do
    it { expect(repository.resource_path).to eq("/repositories/some-project") }
  end

  describe "#mine?" do
    it "returns true" do
      Codeplane.username = "john"
      repository = Codeplane::Resource::Repository.new(:user => {:username => "john"})
      expect(repository).to be_mine
    end

    it "returns false" do
      Codeplane.username = "mary"
      repository = Codeplane::Resource::Repository.new(:user => {:username => "john"})
      expect(repository).not_to be_mine
    end
  end

  describe "#destroy" do
    it "raises error when trying to remove a repository that's not mine" do
      Codeplane.username = "mary"
      repository = Codeplane::Resource::Repository.new(:user => {:username => "john"})

      expect {
        repository.destroy
      }.to raise_error(Codeplane::OwnershipError)
    end

    it "removes my repository" do
      FakeWeb.register_uri :delete, "https://john:abc@codeplane.com/api/v1/repositories/some-repo", :status => 200
      default_credentials!
      repository = Codeplane::Resource::Repository.new(:id => 1234, :name => "some-repo", :user => {:username => "john"}, :collection_resource_path => "/repositories")
      repository.destroy
    end
  end

  describe "#attributes" do
    it { expect(repository).to respond_to(:id) }
    it { expect(repository).to respond_to(:name) }
    it { expect(repository).to respond_to(:usage) }
    it { expect(repository).to respond_to(:created_at) }
    it { expect(repository).to respond_to(:user) }
    it { expect(repository).to respond_to(:errors) }
    it { expect(repository).to respond_to(:uri) }

    it {
      expect {
        repository.attributes
      }.to_not raise_error
    }

    it {
      expect(repository.attributes).to eql(:repository => {:name => "some-project"})
    }

    it { expect(repository.collection_resource_path).to eq("/repositories") }
    it { expect(repository.to_param).to eq("some-project") }
  end
end
