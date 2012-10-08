require 'spec_helper'

describe FoiTicket do
  include ValidatorHelper

  it "should return no errors on valid params" do
    test_data = {
        name: "test name",
        email: "a@a.com",
        email_confirmation: "a@a.com",
        textdetails: "test foi"
    }
    ticket = FoiTicket.new test_data
    ticket.valid?.should eq true
  end

  it "should return email error with invalid email" do
    test_data = {
        name: "test name",
        email: "a",
        email_confirmation: "a@a",
        textdetails: "test foi"
    }
    ticket = FoiTicket.new test_data
    (ticket.errors.has_key? :email).should eq true
  end

  it "should return email error with empty email" do
    test_data = {
        name: "test name",
        email: "",
        email_confirmation: "a@a",
        textdetails: "test foi"
    }
    ticket = FoiTicket.new test_data
    (ticket.errors.has_key? :email).should eq true
  end

  it "should return email error with non matching verification email" do
    test_data = {
        name: "test name",
        email: "a@a",
        email_confirmation: "a@b",
        textdetails: "test foi"
    }
    ticket = FoiTicket.new test_data
    (ticket.errors.has_key? :email).should eq true
  end

  it "should return name error with empty name" do
    test_data = {
        name: "",
        email: "a@a",
        email_confirmation: "a@a",
        textdetails: "test foi"
    }
    ticket = FoiTicket.new test_data
    (ticket.errors.has_key? :name).should eq true
  end

  it "should return foi error with empty textdetails" do
    test_data = {
        name: "test name",
        email: "a@a",
        email_confirmation: "a@a",
        textdetails: ""
    }
    ticket = FoiTicket.new test_data
    (ticket.errors.has_key? :textdetails).should eq true
  end

  it "should return foi error with too long foi text" do
    textdetails = build_random_string 1201
    test_data = {
        name: "test name",
        email: "a@a",
        email_confirmation: "a@a",
        textdetails: textdetails
    }
    ticket = FoiTicket.new test_data
    (ticket.errors.has_key? :textdetails).should eq true
  end
end
