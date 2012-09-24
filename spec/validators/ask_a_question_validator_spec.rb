require 'spec_helper'
require 'ask_a_question_validator'

describe AskAQuestionValidator do
  include ValidatorHelper

  before :each do
    @validator_class = AskAQuestionValidator
    @valid_details = {question: "test question"}
  end

  it_should_behave_like "user details validation"

  it "should return question error with empty question" do
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      question: ""
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:question].should_not be_nil
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

  it "should return question error with too long question" do
    question = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      question: question
    }
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:question].should_not be_nil
  end
end
