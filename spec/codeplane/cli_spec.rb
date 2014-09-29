require "spec_helper"

describe Codeplane::CLI do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  it "sets config file path" do
    expect(Codeplane::CLI.config_file).to eq(File.expand_path("~/.codeplane"))
  end

  context "exception handling" do
    it "wraps Codeplane::UnauthorizedError" do
      expect(Codeplane::CLI).to receive(:command_class_for).and_raise(Codeplane::UnauthorizedError)
      expect(Codeplane::CLI).to receive(:exit).with(1).and_raise(SystemExit)

      expect {
        Codeplane::CLI.start(%w[setup], "", "")
      }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("We couldn't authenticate you. Double check your credentials.")
    end

    it "wraps uncaught exceptions" do
      expect(Codeplane::CLI).to receive(:command_class_for).and_raise(Exception)
      expect(Codeplane::CLI).to receive(:exit).with(1).and_raise(SystemExit)

      expect {
        Codeplane::CLI.start([], "", "")
      }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("Something went wrong.")
    end
  end

  context "invalid commands" do
    it "displays help for empty args" do
      expect(Codeplane::CLI::Help).to receive(:help).once
      Codeplane::CLI.start([], stdout, stderr)
    end

    it "displays help" do
      expect(Codeplane::CLI::Help).to receive(:help).once

      expect {
        Codeplane::CLI.start(%w[invalid:command], stdout, stderr)
      }.to raise_error
    end

    it "exits" do
      expect_any_instance_of(Codeplane::CLI::Help).to receive(:exit).with(1).and_raise(SystemExit)

      expect {
        Codeplane::CLI.start(%w[invalid:command], stdout, stderr)
      }.to raise_error(SystemExit)
    end
  end

  context "subcommand" do
    it "executes original argument" do
      expect_any_instance_of(Codeplane::CLI::Setup).to receive(:perform).once
      Codeplane::CLI.start(%w[setup:perform], stdout, stderr)
    end

    it "defaults to base when available" do
      expect_any_instance_of(Codeplane::CLI::Setup).to receive(:respond_to?).and_return(true)
      expect_any_instance_of(Codeplane::CLI::Setup).to receive(:base).once
      Codeplane::CLI.start(%w[setup], stdout, stderr)
    end

    it "executes help command when don't respond to base" do
      expect_any_instance_of(Codeplane::CLI::Setup).to receive(:respond_to?).and_return(false)
      expect(Codeplane::CLI::Setup).to receive(:help).once

      expect {
        Codeplane::CLI.start(%w[setup], stdout, stderr)
      }.to raise_error
    end
  end
end
