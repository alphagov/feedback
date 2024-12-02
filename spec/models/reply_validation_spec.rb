require "rails_helper"

class TestReplyValidationClass
  include ActiveModel::Model
  include ReplyValidation
end

RSpec.describe ReplyValidation, type: :model do
  include ValidatorHelper

  context "when reply validation is valid" do
    it "returns true if reply yes, email and name present" do
      attributes = {
        reply: "yes",
        name: "Zeus",
        email: "somthing@something.com",
      }
      test_class = TestReplyValidationClass.new(attributes)

      expect(test_class.valid?).to eq(true)
    end

    it "returns true if reply yes, email present" do
      attributes = { reply: "yes", email: "somthing@something.com" }
      test_class = TestReplyValidationClass.new(attributes)

      expect(test_class.valid?).to eq(true)
    end

    it "returns true if reply no" do
      attributes = { reply: "no" }
      test_class = TestReplyValidationClass.new(attributes)

      expect(test_class.valid?).to eq(true)
    end
  end

  context "when reply validation is invalid" do
    it "returns an error if reply is missing" do
      attributes = { reply: "" }
      test_class = TestReplyValidationClass.new(attributes)

      test_class.valid?

      expect(test_class.errors[:reply]).to eq(
        ["Select yes if you want a reply"],
      )
    end

    it "returns an error if reply yes but email missing" do
      attributes = { reply: "yes", email: "" }
      test_class = TestReplyValidationClass.new(attributes)

      test_class.valid?

      expect(test_class.errors[:email]).to eq(
        ["Enter an email address"],
      )
    end

    it "returns an error if the email is invalid" do
      attributes = { reply: "yes", email: "asjdojkko" }
      test_class = TestReplyValidationClass.new(attributes)

      test_class.valid?

      expect(test_class.errors[:email]).to eq(
        ["Enter an email address in the correct format, like name@example.com"],
      )
    end

    it "returns an error if name has too many characters" do
      attributes = {
        reply: "yes",
        name: build_random_string(1251),
        email: "somthing@something.com",
      }
      test_class = TestReplyValidationClass.new(attributes)

      test_class.valid?

      expect(test_class.errors[:name]).to eq(
        ["Your name must be 1250 characters or less"],
      )
    end

    it "returns an error if email has too many characters" do
      attributes = {
        reply: "yes",
        name: "Zeus",
        email: build_random_string(1251),
      }
      test_class = TestReplyValidationClass.new(attributes)

      test_class.valid?

      expect(test_class.errors[:email]).to include(
        "Your email address must be 1250 characters or less",
      )
    end
  end
end
