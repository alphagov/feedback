require 'spec_helper'
require 'contact_validator'

describe ContactValidator do
  include ValidatorHelper

  it "should return contact error with empty textdetails" do
    test_data = {
      name: "test name",
      email: "a@a",
      textdetails: ""
    }
    validator = ContactValidator.new test_data
    errors = validator.validate
    errors[:textdetails].should_not be_nil
  end

  it "should return contact error with too long name" do
    name = build_random_string 1201
    test_data = {
        name: name,
        email: "a@a",
        textdetails: "test text details"
    }
    validator = ContactValidator.new test_data
    errors = validator.validate
    errors[:name].should_not be_nil
  end

  it "should return contact error with bad email" do
    email = (build_random_string 12)
    test_data = {
        name: "test name",
        email: email,
        textdetails: "test text details"
    }
    validator = ContactValidator.new test_data
    errors = validator.validate
    errors[:email].should_not be_nil
  end

  it "should return contact error with too long email" do
    email = (build_random_string 1201) + "@a.com"
    test_data = {
        name: "test name",
        email: email,
        textdetails: "test text details"
    }
    validator = ContactValidator.new test_data
    errors = validator.validate
    errors[:email].should_not be_nil
  end

  it "should return contact error with too long textdetails" do
    textdetails = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      textdetails: textdetails
    }
    validator = ContactValidator.new test_data
    errors = validator.validate
    errors[:textdetails].should_not be_nil
  end
end
