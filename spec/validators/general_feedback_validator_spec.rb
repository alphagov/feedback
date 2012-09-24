require 'spec_helper'
require 'general_feedback_validator'

describe GeneralFeedbackValidator do
  before :each do
    @validator_class = GeneralFeedbackValidator
    @valid_details = {feedback: "feedback"}
  end

  it_should_behave_like BaseValidator

  it "should return feedback error with empty feedback" do
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      feedback: ""
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:feedback].should_not be_nil
  end

  it "should return feedback error with too long feedback" do
    feedback = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      feedback: feedback
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:feedback].should_not be_nil
  end
end
