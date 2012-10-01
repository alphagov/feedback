require 'spec_helper'
require 'foi_validator'

describe FoiValidator do
  include ValidatorHelper

  before :each do
    @validator_class = FoiValidator
    @valid_details = {textdetails: "test foi"}
  end

  it_should_behave_like "user details validation"

  it "should return foi error with empty foi" do
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      textdetails: ""
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:textdetails].should_not be_nil
  end

  it "should return foi error with empty foi" do
    textdetails = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      textdetails: textdetails
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:textdetails].should_not be_nil
  end
end
