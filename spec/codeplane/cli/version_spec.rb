require "spec_helper"

describe Codeplane::CLI::Version do
  subject(:command) { described_class.new }

  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
  end

  it { expect(command.skip_credentials?).to be_truthy }
end
