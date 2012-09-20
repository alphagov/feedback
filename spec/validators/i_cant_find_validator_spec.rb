require 'spec_helper'

describe ICantFindValidator do
  before :each do
    @validator_class = ICantFindValidator
    @valid_details = {lookingfor: "test lookingfor"}
  end

  it_should_behave_like BaseValidator

  it "should return lookingfor error with empty lookingfor" do
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      lookingfor: ""
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:lookingfor].should_not be_nil
  end

  it "should return searchterms error with too long searchterms" do
    searchterms = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      searchterms: searchterms
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:searchterms].should_not be_nil
  end

  it "should return lookingfor error with too long lookingfor" do
    lookingfor = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      lookingfor: lookingfor
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:lookingfor].should_not be_nil
  end
end
