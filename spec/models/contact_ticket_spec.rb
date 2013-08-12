require 'spec_helper'

describe ContactTicket do
  include ValidatorHelper

  def valid_anonymous_ticket_details
    {
      textdetails: "some text",
      query: "cant-find",
      location: "all"
    }
  end

  def valid_named_ticket_details
    valid_anonymous_ticket_details.merge(name: "Joe Bloggs", email: "ab@c.com")
  end

  def anon_ticket
    anon_ticket_with()
  end

  def anon_ticket_with(options = {})
    ContactTicket.new valid_anonymous_ticket_details.merge(options)
  end

  def named_ticket_with(options = {})
    ContactTicket.new valid_named_ticket_details.merge(options)
  end

  it "should validate anonymous tickets" do
    anon_ticket.should be_valid
  end

  it "should validate named tickets" do
    named_ticket_with().should be_valid
  end

  it "should return contact error with empty textdetails" do
    anon_ticket_with(textdetails: "").should have(1).error_on(:textdetails)
  end

  it "should return contact error with too long name" do
    named_ticket_with(name: build_random_string(1251)).should have(1).error_on(:name)
  end

  it "should return contact error with bad email" do
    named_ticket_with(email: build_random_string(12)).should have(1).error_on(:email)
  end

  it "should not be valid if the email contains spaces" do
    named_ticket_with(email: "abc @d.com").should have(1).error_on(:email)
  end

  it "should return contact error with too long email" do
    named_ticket_with(email: (build_random_string 1251) + "@a.com").should have(1).error_on(:email)
  end

  it "should return contact error with location specific but without link" do
    anon_ticket_with(location: "specific").should have(1).error_on(:link)
  end

  it "should return contact error with too long textdetails" do
    anon_ticket_with(textdetails: build_random_string(1251)).should have(1).error_on(:textdetails)
  end

  it "should save the user agent and javascript state" do
    expected_user_agent = "Mozilla/5.0 (Windows NT 6.2; WOW64) Gobble-de-gook"
    expected_javascript_state = true

    ticket = anon_ticket_with(user_agent: expected_user_agent,
      javascript_enabled: expected_javascript_state)

    ticket.user_agent.should eq expected_user_agent
    ticket.javascript_enabled.should eq expected_javascript_state
  end

  it "should set the javascript state to false by default" do
    anon_ticket.javascript_enabled.should be_false
  end

  it "should set user agent to 'unknown' when none given" do
    anon_ticket.user_agent.should == "unknown"
  end

  it "should validate that an allowed contact reason is present" do
    anon_ticket_with(query: "non-existent").should have(1).error_on(:query)
    anon_ticket_with(query: "").should have(1).error_on(:query)
    anon_ticket_with(query: nil).should have(1).error_on(:query)
  end

  it "should make sure that a location is present" do
    anon_ticket_with(location: "").should have(1).error_on(:location)
    anon_ticket_with(location: nil).should have(1).error_on(:location)
  end
end
