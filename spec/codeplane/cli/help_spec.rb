require "spec_helper"

describe Codeplane::CLI::Help do
  subject(:command) { described_class.new }

  before do
    Codeplane::CLI.stdout = StringIO.new
    Codeplane::CLI.stderr = StringIO.new
  end

  it { expect(command.skip_credentials?).to be_truthy }

  it "displays help for all known commands" do
    expect(Codeplane::CLI::Help).to receive(:help).ordered.once
    expect(Codeplane::CLI::Setup).to receive(:help).ordered.once
    expect(Codeplane::CLI::Auth).to receive(:help).ordered.once
    expect(Codeplane::CLI::Repo).to receive(:help).ordered.once
    expect(Codeplane::CLI::User).to receive(:help).ordered.once

    command.base
  end

  it "displays help specified command" do
    expect(Codeplane::CLI::Setup).to receive(:help).once
    expect(Codeplane::CLI::Help).not_to receive(:help)
    expect(Codeplane::CLI::Auth).not_to receive(:help)
    expect(Codeplane::CLI::Repo).not_to receive(:help)
    expect(Codeplane::CLI::User).not_to receive(:help)

    command = Codeplane::CLI::Help.new(%w[setup])
    command.base
  end

  it "display help's help for invalid commands" do
    expect(Codeplane::CLI::Help).to receive(:help).once
    expect(Codeplane::CLI::Setup).not_to receive(:help)
    expect(Codeplane::CLI::Auth).not_to receive(:help)
    expect(Codeplane::CLI::Repo).not_to receive(:help)
    expect(Codeplane::CLI::User).not_to receive(:help)

    command = Codeplane::CLI::Help.new(%w[invalid])
    expect(command).to receive(:exit).with(1).and_raise(SystemExit)

    expect {
      command.base
    }.to raise_error(SystemExit)
  end
end
