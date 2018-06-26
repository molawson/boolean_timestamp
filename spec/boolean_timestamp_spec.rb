RSpec.describe BooleanTimestamp do
  it "has a version number" do
    expect(BooleanTimestamp::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
