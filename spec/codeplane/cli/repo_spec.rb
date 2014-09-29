require "spec_helper"

describe Codeplane::CLI::Repo do
  before do
    Codeplane::CLI.stdout = ""
    Codeplane::CLI.stderr = ""
    subject.client.repositories.stub :all => []
  end

  describe "#add" do
    it "displays message" do
      subject.client.repositories.stub :create => double(:valid? => true, :uri => "repo.git")
      expect { subject.add }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stdout).to include("Your Git url is repo.git\nGive it some time before cloning it.")
    end

    it "displays error message" do
      subject.client.repositories.stub :create => double(:valid? => false, :errors => ["Something is wrong"])
      expect { subject.add }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stderr).to include("* Something is wrong")
    end
  end

  describe "#remove" do
    before do
      subject.args = ["some-repo"]
      subject.stub :confirmed? => true
    end

    it "exits when have no repositories" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.remove }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("No repositories found")
    end

    it "displays message" do
      repo = double(:mine? => true, :name => "some-repo")
      subject.client.repositories.stub :all => [repo]

      expect(repo).to receive(:destroy).once

      expect { subject.remove }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stdout).to include("The repository 'some-repo' has been removed")
    end

    it "exits when no name is provided" do
      subject.args = []
      expect { subject.remove }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stderr).to include("Provide the repository name")
    end

    it "exits when repository is not found" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      subject.client.repositories.stub :all => [double(:name => "repo-1")]
      subject.args = ["repo-2"]

      expect { subject.remove }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("Couldn't find 'repo-2' repository")
    end

    it "exits when removing shared repo" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      subject.client.repositories.stub :all => [double(:name => "repo-1", :mine? => false)]
      subject.args = ["repo-1"]

      expect { subject.remove }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("You can't remove 'repo-1' because you don't own it")
    end
  end

  describe "#list" do
    it "exits when have no repositories" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      expect { subject.list }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("No repositories found")
    end

    it "displays repository list" do
      subject.client.repositories.stub :all => [
        double(:name => "repo-1", :mine? => true, :uri => "repo-1.git"),
        double(:name => "shared-repo", :mine? => false, :uri => "shared-repo.git")
      ]

      subject.list
      expect(clean(Codeplane::CLI.stdout)).to include("repo-1          # repo-1.git")
      expect(clean(Codeplane::CLI.stdout)).to include("shared-repo*    # shared-repo.git")
    end
  end

  describe "#info" do
    it "exits when no name is provided" do
      subject.args = []
      expect { subject.info }.to raise_error(SystemExit)
      expect(Codeplane::CLI.stderr).to include("Provide the repository name")
    end

    it "exits when repository is not found" do
      expect(subject).to receive(:exit).with(1).and_raise(SystemExit)
      subject.client.repositories.stub :all => [double(:name => "repo-1")]
      subject.args = ["repo-2"]

      expect { subject.info }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stderr).to include("Couldn't find repository 'repo-2'")
    end

    it "displays repository info" do
      subject.client.repositories.stub :all => [
        double(:name => "repo-1", :mine? => true, :uri => "repo-1.git", :usage => 0)
      ]

      subject.args = ["repo-1"]
      expect { subject.info }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stdout).to include("Name: repo-1")
      expect(Codeplane::CLI.stdout).to include("Git url: repo-1.git")
      expect(Codeplane::CLI.stdout).to include("Usage: 0.00 bytes")
      expect(Codeplane::CLI.stdout).to include("Owner: You")
    end

    it "displays shared repository info" do
      subject.client.repositories.stub :all => [
        double(
          :name => "repo-1",
          :usage => 0,
          :user => double(:name => "John Doe", :email => "john@doe.com"),
          :mine? => false
        ).as_null_object
      ]

      subject.args = ["repo-1"]
      expect { subject.info }.to raise_error(SystemExit)

      expect(Codeplane::CLI.stdout).to include("Owner: John Doe (john@doe.com)")
    end
  end
end
