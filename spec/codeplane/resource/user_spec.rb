require "spec_helper"

describe Codeplane::Resource::User do
  subject { Codeplane::Resource::User.new }

  describe "#attributes" do
    it { is_expected.to respond_to(:id) }
    it { is_expected.to respond_to(:username) }
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:usage) }
    it { is_expected.to respond_to(:storage) }
    it { is_expected.to respond_to(:created_at) }
    it { is_expected.to respond_to(:time_zone) }
  end

  context "remove methods" do
    it { is_expected.not_to respond_to(:save) }
    it { is_expected.not_to respond_to(:attributes) }
    it { is_expected.not_to respond_to(:resource_path) }
  end
end
