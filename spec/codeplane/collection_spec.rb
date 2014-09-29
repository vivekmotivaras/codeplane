require "spec_helper"

describe Codeplane::Collection do
  subject(:collection) {
    Codeplane::Collection.new(
      :resource_path => "/things",
      :resource_class_name => "Thing"
    )
  }

  describe "#initialize" do
    it { expect(collection.resource_path).to eq("/things") }
    it { expect(collection.resource_class_name).to eq("Thing") }

    it "includes extension" do
      mod = Module.new
      expect(Codeplane::Collection.new(:extension => mod).singleton_class.included_modules).to include(mod)
    end
  end

  describe "#resource_class" do
    it "retrieves specified class" do
      collection.resource_class_name = "Thing"
      expect(collection.resource_class).to eq(Codeplane::Resource::Thing)
    end
  end

  describe "#all" do
    before do
      default_credentials!
      FakeWeb.register_uri :get, "https://john:abc@codeplane.com/api/v1/things", :body => fixtures.join("things.json").read
    end

    it "retrieves all items" do
      expect(collection.all.size).to eq(3)
    end

    it "builds objects" do
      expect(collection.all[0]).to be_a(Codeplane::Resource::Thing)
      expect(collection.all[1]).to be_a(Codeplane::Resource::Thing)
      expect(collection.all[2]).to be_a(Codeplane::Resource::Thing)
    end

    it "sets attributes" do
      thing = collection.all[0]
      expect(thing.name).to eq("macbook")
      expect(thing.id).to eq(1)
      expect(thing.collection_resource_path).to eq("/things")
    end
  end

  describe "#each" do
    it "includes Enumerable" do
      expect(Codeplane::Collection.included_modules).to include(Enumerable)
    end

    it "returns an enumerator" do
      default_credentials!
      FakeWeb.register_uri :get, "https://john:abc@codeplane.com/api/v1/things", :body => "[]"
      expect(collection.each).to be_an(Enumerator)
    end
  end

  describe "#build" do
    it "returns a resource instance" do
      expect(collection.build).to be_a(Codeplane::Resource::Thing)
    end

    it "sets attributes" do
      thing = collection.build(:name => "book")
      expect(thing.name).to eq("book")
    end
  end

  describe "#create" do
    it "builds a new instance" do
      expect(collection).to receive(:build).with(:name => "book").and_return(double.as_null_object)
      collection.create(:name => "book")
    end

    it "calls the #save method" do
      thing = double(Codeplane::Resource::Thing)
      collection.stub :build => thing

      expect(thing).to receive(:save).once
      collection.create
    end
  end

  describe "#count" do
    before { allow(collection).to receive(:all).and_return([1,2,3]) }

    it { expect(collection.count).to eq(3) }
    it { expect(collection.size).to eq(3) }
  end
end
