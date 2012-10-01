require 'spec_helper'
require 'foi_validator'

describe FoiValidator do
  include ValidatorHelper

  before :each do
    @valid_details = {textdetails: "test foi"}
  end

  it "should return no errors on valid params" do
    test_data = {
        name: "test name",
        email: "a@a.com",
        verifyemail: "a@a.com"
    }
    test_data = test_data.merge @valid_details
    validator = FoiValidator.new test_data
    errors = validator.validate
    errors.should be_empty
  end

  it "should return email error with invalid email" do
    test_data = {
        name: "test name",
        email: "a",
        verifyemail: "a@a"
    }
    test_data = test_data.merge @valid_details
    validator = FoiValidator.new test_data
    errors = validator.validate
    errors[:email].should_not be_nil
  end

  it "should return email error with empty email" do
    test_data = {
        name: "test name",
        email: "",
        verifyemail: "a@a"
    }
    test_data = test_data.merge @valid_details
    validator = FoiValidator.new test_data
    errors = validator.validate
    errors[:email].should_not be_nil
  end

  it "should return email error with non matching verification email" do
    test_data = {
        name: "test name",
        email: "a@a",
        verifyemail: "a@b"
    }
    test_data = test_data.merge @valid_details
    validator = FoiValidator.new test_data
    errors = validator.validate
    errors[:email].should_not be_nil
  end

  it "should return name error with empty name" do
    test_data = {
        name: "",
        email: "a@a",
        verifyemail: "a@a"
    }
    test_data = test_data.merge @valid_details
    validator = FoiValidator.new test_data
    errors = validator.validate
    errors[:name].should_not be_nil
  end

  it "should return foi error with empty foi" do
    test_data = {
        name: "test name",
        email: "a@a",
        verifyemail: "a@a",
        textdetails: ""
    }
    validator = FoiValidator.new test_data
    errors = validator.validate
    errors[:textdetails].should_not be_nil
  end

  it "should return foi error with too long foi text" do
    textdetails = build_random_string 1201
    test_data = {
        name: "test name",
        email: "a@a",
        verifyemail: "a@a",
        textdetails: textdetails
    }
    validator = FoiValidator.new test_data
    errors = validator.validate
    errors[:textdetails].should_not be_nil
  end
end
