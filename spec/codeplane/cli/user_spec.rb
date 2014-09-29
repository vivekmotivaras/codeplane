require "spec_helper"

describe Codeplane::CLI::User do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
    subject.client.repositories.stub :all => [
      double(:name => "repo", :mine? => true, :collaborators => double(:all => []))
    ]

    subject.args = ["repo"]
  end

  describe "#list" do
    it "lists collaborators" do
      subject.client.repositories.first.collaborators.stub :all => [
        double(:name => "John Doe", :email => "john@doe.com"),
        double(:name => "Tim Doe", :email => "tim@doe.com")
      ]

      subject.list

      expect(clean(Codeplane::CLI.stdout)).to include("John Doe    # john@doe.com")
      expect(clean(Codeplane::CLI.stdout)).to include("Tim Doe     # tim@doe.com")
    end

    it "exits when have no collaborators" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("No collaborators were added to 'repo'")
    end

    it "exits when trying to list shared repository's collaborators" do
      subject.client.repositories.first.collaborators.stub :all => [
        double(:name => "John Doe", :email => "john@doe.com")
      ]
      subject.client.repositories.first.stub :mine? => false
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("Couldn't find 'repo' repository")
    end

    it "exits when repository is not found" do
      subject.args = ["another-repo"]
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("Couldn't find 'another-repo' repository")
    end

    it "exits when no repository name is provided" do
      subject.args = []
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("Provide the repository name")
    end
  end

  describe "#add" do
    it "displays message" do
      subject.args = ["repo", "john@doe.com"]
      expect(subject.client.repositories.all.first.collaborators).to receive(:invite).with("john@doe.com").and_return(double(:valid? => true, :email => "john@doe.com"))

      expect { subject.add }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stdout).to include("We sent an invitation to john@doe.com")
    end

    it "displays errors" do
      subject.args = ["repo", "john@doe.com"]
      expect(subject.client.repositories.all.first.collaborators).to receive(:invite).with("john@doe.com").and_return(double(:valid? => false, :errors => ["Something is wrong"]))
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)

      expect { subject.add }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stderr).to include("* Something is wrong")
    end
  end

  describe "#remove" do
    let(:repo) { subject.client.repositories.all.first }

    it "displays message" do
      subject.args = ["repo", "john@doe.com"]
      expect(repo.collaborators).to receive(:remove).with("john@doe.com").and_return(double(:success? => true))

      expect { subject.remove }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stdout).to include("We revoked john@doe.com permissions on 'repo'")
    end

    it "display errors" do
      subject.args = ["repo", "john@doe.com"]
      expect(repo.collaborators).to receive(:remove).with("john@doe.com").and_raise(Codeplane::NotFoundError)
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)

      expect { subject.remove }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stderr).to include("We couldn't find this collaborator")
    end
  end
end
