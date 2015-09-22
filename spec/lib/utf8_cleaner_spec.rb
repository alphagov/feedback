require 'spec_helper'

describe UTF8Cleaner do
  include UTF8Cleaner

  it "should remove non-UTF8 chars from strings" do
    expect(sanitise("\xFF\xFEother data")).to eq("other data")
  end

  it "should not touch non-strings" do
    expect(sanitise(:something)).to eq(:something)
  end

  it "should sanitise hashes" do
    expect(sanitised(abc: "\xFF\xFEdef", ghi: "jkl")).to eq(abc: "def", ghi: "jkl")
  end
end