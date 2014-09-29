require "spec_helper"

describe Codeplane::CLI::Auth do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
    subject.client.public_keys.stub :all => []
  end

  describe "#list" do
    it "lists public keys" do
      subject.client.public_keys.stub :all => [
        double(:name => "server", :fingerprint => "aa:bb:cc"),
        double(:name => "example.com", :fingerprint => "dd:ee:ff")
      ]

      subject.list
      expect(clean(Codeplane::CLI.stdout)).to include("server         # aa:bb:cc")
      expect(clean(Codeplane::CLI.stdout)).to include("example.com    # dd:ee:ff")
    end

    it "exits when have no public keys" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("No SSH keys were added")
    end
  end

  describe "#add" do
    before do
      subject.args = ["server", fixtures.join("id_rsa.pub").to_s]
    end

    it "displays message" do
      expect(subject.client.public_keys).to receive(:create).with(:name => "server", :key => fixtures.join("id_rsa.pub").read).and_return(double(:valid? => true, :name => "server"))
      expect { subject.add }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stdout).to include("Your SSH public key 'server' was added")
    end

    it "displays error message" do
      subject.client.public_keys.stub :create => double(:valid? => false, :errors => ["Something is wrong"])
      expect { subject.add }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stderr).to include("* Something is wrong")
    end
  end

  describe "#remove" do
    before do
      subject.args = ["some key"]
    end

    it "exits when have no public keys" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.remove }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("No SSH keys were added")
    end

    it "displays message" do
      key = double(:name => "some key")
      expect(key).to receive(:destroy).once
      subject.client.public_keys.stub :all => [key]
      expect { subject.remove }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stdout).to include("The SSH key 'some key' has been removed")
    end

    it "exits when no name is provided" do
      subject.args = []
      expect { subject.remove }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stderr).to include("Provide the SSH key name")
    end

    it "exits when repository is not found" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      subject.client.public_keys.stub :all => [double(:name => "my key")]
      subject.args = ["example.com"]

      expect { subject.remove }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("Couldn't find 'example.com' key")
    end
  end
end
