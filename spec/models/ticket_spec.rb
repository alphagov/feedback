require 'spec_helper'

describe Ticket do
  it "should be marked as spam if a bot has populated the val field" do
    Ticket.new(val: "xxxxx").should be_spam
    Ticket.new(val: "xxxxx").should_not be_valid
  end

  it "should not be spam by default" do
    Ticket.new.should_not be_spam
  end
end
