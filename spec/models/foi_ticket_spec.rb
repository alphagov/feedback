require 'spec_helper'
require 'rspec/expectations'

RSpec::Matchers.define :have_errors_on do |expected_attribute_name|
  match do |model|
    model.errors.has_key?(expected_attribute_name)
  end
end

describe FoiTicket do
  include ValidatorHelper

  def valid_foi_request_defaults
    {
      name: "test name",
      email: "a@a.com",
      email_confirmation: "a@a.com",
      textdetails: "test foi"
    }
  end

  def foi_request(options = {})
    FoiTicket.new(valid_foi_request_defaults.merge(options))
  end

  it "should return no errors on valid params" do
    foi_request.should be_valid
  end

  it "should return email error with invalid email" do
    foi_request(email: "a").should have_errors_on(:email)
  end

  it "should return email error with empty email" do
    foi_request(email: "").should have_errors_on(:email)
  end

  it "should return email error with non matching verification email" do
    foi_request(email: "a@a", email_confirmation: "a@b").should have_errors_on(:email)
  end

  it "should return name error with empty name" do
    foi_request(name: "").should have_errors_on(:name)
  end

  it "should return foi error with empty textdetails" do
    foi_request(textdetails: "").should have_errors_on(:textdetails)
  end

  it "should return foi error with too long foi text" do
    foi_request(textdetails: build_random_string(1251)).should have_errors_on(:textdetails)
  end

  it "should raise an exception if zendesk ticket creation fails" do
    ticket = foi_request
    ticket.stub(:ticket_client).and_raise('some error')
    lambda { ticket.save }.should raise_error('some error')
  end
end
