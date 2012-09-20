require 'spec_helper'

describe AskAQuestionValidator do
  it "should return no errors on valid params" do
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      question: "test question"
    }
    validator = AskAQuestionValidator.new test_data
    errors = validator.validate
    errors.should be_empty
  end

  it "should return email error with invalid email" do
    test_data = {
      name: "test name",
      email: "a",
      verifyemail: "a@a",
      question: "test question"
    }
    validator = AskAQuestionValidator.new test_data
    errors = validator.validate
    errors[:email].should_not be_nil
  end

  it "should return email error with empty email" do
    test_data = {
      name: "test name",
      email: "",
      verifyemail: "a@a",
      question: "test question"
    }
    validator = AskAQuestionValidator.new test_data
    errors = validator.validate
    errors[:email].should_not be_nil
  end

  it "should return email error with non matching verification email" do
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@b",
      question: "test question"
    }
    validator = AskAQuestionValidator.new test_data
    errors = validator.validate
    errors[:email].should_not be_nil
  end

  it "should return name error with empty name" do
    test_data = {
      name: "",
      email: "a@a",
      verifyemail: "a@a",
      question: "test question"
    }
    validator = AskAQuestionValidator.new test_data
    errors = validator.validate
    errors[:name].should_not be_nil
  end

  it "should return question error with empty question" do
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      question: ""
    }
    validator = AskAQuestionValidator.new test_data
    errors = validator.validate
    errors[:question].should_not be_nil
  end

  it "should return question error with empty question" do
    question = build_random_string 1201
    test_data = {
      name: "test name",
      email: "a@a",
      verifyemail: "a@a",
      question: question
    }
    validator = AskAQuestionValidator.new test_data
    errors = validator.validate
    errors[:question].should_not be_nil
  end

  def build_random_string(len)
    chars = [ *'a'..'z', *'0'..'9' ]
    r = ''
    len.times { r << chars[rand(36)] }
    r
  end
end
