require "spec_helper"

describe Codeplane::CLI::Setup do
  subject(:command) { described_class.new }

  before do
    Codeplane::CLI.stub :config_file => "/tmp/codeplane_config"
    FileUtils.rm(Codeplane::CLI.config_file) rescue nil

    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
    allow(Codeplane::Request).to receive :get
    command.stub :gets => ""
  end

  it { expect(command.skip_credentials?).to be_truthy }

  it "sets credentials" do
    expect(command).to receive(:gets).and_return("the_real_john\n", "some_api_key\n")
    command.base

    expect(Codeplane.username).to eq("the_real_john")
    expect(Codeplane.api_key).to eq("some_api_key")
  end

  it "makes API call" do
    expect(Codeplane::Request).to receive(:get).with("/auth")
    command.base
  end

  it "displays success message" do
    expect {
      command.base
    }.to_not raise_error

    expect(Codeplane::CLI.stdout).to include("Your credentials were saved at ~/.codeplane and chmoded as 0600.")
  end

  it "saves credentials to filesystem" do
    expect(command).to receive(:gets).and_return("the_real_john\n", "some_api_key\n")
    command.base

    expect(File).to be_file(Codeplane::CLI.config_file)
    expect(YAML.load_file(Codeplane::CLI.config_file)).to eq({:username => "the_real_john", :api_key => "some_api_key"})
    expect(File).not_to be_world_writable(Codeplane::CLI.config_file)
    expect(File).not_to be_world_readable(Codeplane::CLI.config_file)
  end
end
