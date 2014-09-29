require "spec_helper"

describe Codeplane::CLI::Base do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
  end

  describe "#run" do
    it "raises unauthorized exception when credentials aren't set" do
      Codeplane::CLI.stub :credentials? => false

      expect {
        Codeplane::CLI::Repo.new([]).run("base")
      }.to raise_error(Codeplane::UnauthorizedError)
    end

    it "executes command when credentials are set" do
      Codeplane::CLI.stub :credentials? => true
      expect_any_instance_of(Codeplane::CLI::Repo).to receive(:base)

      expect {
        Codeplane::CLI::Repo.new([]).run("base")
      }.to_not raise_error
    end

    it "executes command when skip_credentials is set" do
      Codeplane::CLI.stub :credentials? => false
      Codeplane::CLI.stub :skip_credentials? => true
      expect_any_instance_of(Codeplane::CLI::Setup).to receive(:base)

      expect {
        Codeplane::CLI::Setup.new([]).run("base")
      }.to_not raise_error
    end
  end

  describe "#confirmed?" do
    subject { Codeplane::CLI::Base.new }

    it "bypasses confirmation" do
      subject.args = ["--confirm"]
      expect(subject).to be_confirmed
    end

    it "accepts 'y' as confirmation" do
      subject.args = []

      expect(subject).to receive(:gets).and_return("y\n")
      expect(subject).to be_confirmed
    end

    it "accepts 'yes' as confirmation" do
      subject.args = []

      expect(subject).to receive(:gets).and_return("yes\n")
      expect(subject).to be_confirmed
    end

    it "rejects anything else" do
      subject.args = []

      expect(subject).to receive(:gets).and_return("n\n")

      expect { expect(subject).not_to be_confirmed }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stdout).to include("Not doing anything")
    end
  end
end
