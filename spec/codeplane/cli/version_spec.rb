require "spec_helper"

describe Codeplane::CLI::Version do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
  end

  its(:skip_credentials?) { should be_true }
end
