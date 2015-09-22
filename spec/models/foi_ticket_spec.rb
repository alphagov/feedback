require 'spec_helper'
require 'gds_api/test_helpers/support'

describe FoiTicket do
  include ValidatorHelper
  include GdsApi::TestHelpers::Support

  def valid_foi_request_defaults
    {
      name: "test name",
      email: "a@a.com",
      email_confirmation: "a@a.com",
      textdetails: "test foi"
    }
  end

  def foi_request(options = {})
    FoiTicket.new(valid_foi_request_defaults.merge(options))
  end

  it "should return no errors on valid params" do
    expect(foi_request).to be_valid
  end

  it "should return email error with invalid email" do
    expect(foi_request(email: "a", email_confirmation: "a").errors[:email].size).to eq(1)
  end

  it "should return email error with empty email" do
    expect(foi_request(email: "", email_confirmation: "").errors[:email].size).to be >= 1
  end

  it "should return email error with non matching verification email" do
    expect(foi_request(email: "a@a.com", email_confirmation: "a@b.com").errors[:email_confirmation].size).to eq(1)
  end

  it "should return name error with empty name" do
    expect(foi_request(name: "").errors[:name].size).to eq(1)
  end

  it "should return foi error with empty textdetails" do
    expect(foi_request(textdetails: "").errors[:textdetails].size).to eq(1)
  end

  it "should return foi error with too long foi text" do
    expect(foi_request(textdetails: build_random_string(1251)).errors[:textdetails].size).to eq(1)
  end

  it "should raise an exception if support isn't available" do
    support_isnt_available
    expect { foi_request.save }.to raise_error(GdsApi::BaseError)
  end
end
