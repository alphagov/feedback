require 'base_validator'

shared_examples_for BaseValidator do
  it "should return no errors on valid params" do
    test_data = {
      name: "test name",
      email: "a@a.com",
      verifyemail: "a@a.com"
    }
    test_data = test_data.merge @valid_details
    validator = @validator_class.new test_data
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
    validator = @validator_class.new test_data
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
    validator = @validator_class.new test_data
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
    validator = @validator_class.new test_data
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
    validator = @validator_class.new test_data
    errors = validator.validate
    errors[:name].should_not be_nil
  end

  def build_random_string(len)
    chars = [ *'a'..'z', *'0'..'9' ]
    r = ''
    len.times { r << chars[rand(36)] }
    r
  end
end
