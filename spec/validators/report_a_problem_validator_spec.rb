require 'spec_helper'
require 'report_a_problem_validator'

describe ReportAProblemValidator do
  include ValidatorHelper

  before :each do
    @validator_class = ReportAProblemValidator
  end

  it "should return what_wrong error with too long what_wrong" do
    what_wrong = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      what_wrong: what_wrong
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:what_wrong].should_not be_nil
  end

  it "should return what_doing error with too long what_doing" do
    what_doing = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      what_doing: what_doing
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:what_doing].should_not be_nil
  end

end
