require "spec_helper"

describe Codeplane::Resource::PublicKey do
  subject(:public_key) { Codeplane::Resource::PublicKey.new(:id => 1234, :name => "macbook's", :key => "ssh-rsa key") }

  describe "#attributes" do
    it { expect(public_key).to respond_to(:id) }
    it { expect(public_key).to respond_to(:name) }
    it { expect(public_key).to respond_to(:key) }
    it { expect(public_key).to respond_to(:fingerprint) }
    it { expect(public_key).to respond_to(:errors) }

    it {
      expect { public_key.attributes }.to_not raise_error
    }

    it { expect(public_key.to_param).to eq(1234) }

    it {
      payload = {:public_key => {
        :name => "macbook's",
        :key => "ssh-rsa key"
      }}

      expect(public_key.attributes).to eq(payload)
    }
  end
end
