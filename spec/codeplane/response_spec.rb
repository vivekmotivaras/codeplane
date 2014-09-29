require "spec_helper"

describe Codeplane::Response do
  it "returns status code" do
    subject.stub_chain(:raw, :code => "200")
    expect(subject.status).to eq(200)
  end

  it "parses payload" do
    subject.stub_chain(:raw, :body => {:success => true}.to_json)
    expect(subject.payload).to eq({"success" => true})
  end

  it "detects success status" do
    subject.stub_chain(:raw, :code => "204")
    expect(subject).to be_success
  end

  it "detects redirect status" do
    subject.stub_chain(:raw, :code => "302")
    expect(subject).to be_redirect
  end

  it "detects error status" do
    subject.stub_chain(:raw, :code => "500")
    expect(subject).to be_error
  end
end
