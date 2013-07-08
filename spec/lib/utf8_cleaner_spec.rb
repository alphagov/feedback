require 'spec_helper'

describe UTF8Cleaner do
  include UTF8Cleaner

  it "should remove non-UTF8 chars from strings" do
    sanitise("\xFF\xFEother data").should eq("other data")
  end

  it "should not touch non-strings" do
    sanitise(:something).should eq(:something)
  end

  it "should sanitise hashes" do
    sanitised(abc: "\xFF\xFEdef", ghi: "jkl").should eq(abc: "def", ghi: "jkl")
  end
end