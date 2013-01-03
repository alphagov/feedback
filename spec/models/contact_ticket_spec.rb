require 'spec_helper'

describe ContactTicket do
  include ValidatorHelper

  it "should return contact error with empty textdetails" do
    test_data = {
      name: "test name",
      email: "a@a",
      textdetails: ""
    }
    ticket = ContactTicket.new test_data
    (ticket.errors.has_key? :textdetails).should eq true
  end

  it "should return contact error with too long name" do
    name = build_random_string 1251
    test_data = {
        name: name,
        email: "a@a",
        textdetails: "test text details"
    }
    ticket = ContactTicket.new test_data
    (ticket.errors.has_key? :name).should eq true
  end

  it "should return contact error with bad email" do
    email = (build_random_string 12)
    test_data = {
        name: "test name",
        email: email,
        textdetails: "test text details"
    }
    ticket = ContactTicket.new test_data
    (ticket.errors.has_key? :email).should eq true
  end

  it "should return contact error with too long email" do
    email = (build_random_string 1251) + "@a.com"
    test_data = {
        name: "test name",
        email: email,
        textdetails: "test text details"
    }
    ticket = ContactTicket.new test_data
    (ticket.errors.has_key? :email).should eq true
  end

  it "should return contact error with location specific but without link" do
    textdetails = build_random_string 1251
    test_data = {
      name: "test name",
      email: "a@a",
      textdetails: "test text details",
      location: "specific"
    }
    ticket = ContactTicket.new test_data
    (ticket.errors.has_key? :link).should eq true
  end

  it "should return contact error with too long textdetails" do
    textdetails = build_random_string 1251
    test_data = {
      name: "test name",
      email: "a@a",
      textdetails: textdetails
    }
    ticket = ContactTicket.new test_data
    (ticket.errors.has_key? :textdetails).should eq true
  end

  it "should save the user agent and javascript state" do
    expected_user_agent = "Mozilla/5.0 (Windows NT 6.2; WOW64) Gobble-de-gook"
    expected_javascript_state = true

    test_data = {
      name: "test name",
      email: "test@test.com",
      textdetails: build_random_string(100),
      user_agent: expected_user_agent,
      javascript_enabled: expected_javascript_state
    }
    ticket = ContactTicket.new test_data

    ticket.user_agent.should eq expected_user_agent
    ticket.javascript_enabled.should eq expected_javascript_state
  end

  it "should set the javascript state to false by default" do
    test_data = {
      name: "test name",
      email: "test@test.com",
      textdetails: build_random_string(100),
    }
    ticket = ContactTicket.new test_data

    ticket.javascript_enabled.should eq false
  end

  it "should set user agent to 'unknown' when none given" do
    test_data = {
      name: "test name",
      email: "test@test.com",
      textdetails: build_random_string(100),
    }
    ticket = ContactTicket.new test_data
    ticket.user_agent.should eq "unknown"
  end
end
