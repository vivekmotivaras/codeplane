shared_examples_for "resource collection" do
  it "returns a collection" do
    expect(subject.send(collection)).to be_a(Codeplane::Collection)
  end

  it "sets resource's path" do
    expect(subject.send(collection).resource_path).to eq(resource_path)
  end

  it "sets resource's class name" do
    expect(subject.send(collection).resource_class_name).to eq(resource_class_name)
  end

  it "returns resource's class" do
    expect(subject.send(collection).resource_class).to eq(resource_class)
  end

  it "sets parent" do
    expect(subject.send(collection).parent).to eq(subject)
  end
end
