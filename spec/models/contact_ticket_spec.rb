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
    name = build_random_string 1201
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
    email = (build_random_string 1201) + "@a.com"
    test_data = {
        name: "test name",
        email: email,
        textdetails: "test text details"
    }
    ticket = ContactTicket.new test_data
    (ticket.errors.has_key? :email).should eq true
  end

  it "should return contact error with location specific but without link" do
    textdetails = build_random_string 1201
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
    textdetails = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      textdetails: textdetails
    }
    ticket = ContactTicket.new test_data
    (ticket.errors.has_key? :textdetails).should eq true
  end
end
