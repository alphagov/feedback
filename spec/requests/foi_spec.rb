require 'spec_helper'
require 'gds_api/test_helpers/support'

describe "FOI" do
  include GdsApi::TestHelpers::Support

  def fill_in_valid_credentials
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
  end

  it "should let the user submit a FOI request" do
    stub_post = stub_support_foi_request_creation(requester: {name: "test name", email: "a@a.com"}, details: "test foi request")

    visit "/contact/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    fill_in "Provide a detailed description of the information you're seeking", :with => "test foi request"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/contact/foi"

    page.should have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")
    assert_requested(stub_post)
  end

  # this can be deleted when the deprecated routes are dropped
  it "should allow submission on the legacy end-point" do
    stub_support_foi_request_creation
    valid_params = { foi: { name: "A", email: "a@b.com", email_confirmation: "a@b.com", textdetails: "abc" } }

    # Using Rack::Test instead of capybara to allow setting headers.
    post "/feedback/foi", valid_params

    assert_requested(:post, %r{/foi_requests})
  end

  it "should pass the varnish ID through to the support app if set" do
    stub_support_foi_request_creation
    valid_params = { foi: { name: "A", email: "a@b.com", email_confirmation: "a@b.com", textdetails: "abc" } }

    # Using Rack::Test instead of capybara to allow setting headers.
    post "/contact/foi", valid_params, {"HTTP_X_VARNISH" => "12345"}

    assert_requested(:post, %r{/foi_requests}) do |request|
      request.headers["X-Varnish"] == "12345"
    end
  end

  it "recreate non-UTF-char bug" do
    stub_support_foi_request_creation

    visit "/contact/foi"

    fill_in_valid_credentials
    fill_in "Provide a detailed description of the information you're seeking", :with => "\xFF\xFEother data"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/contact/foi"
  end

  it "should still work even if the request doesn't have correct form params" do
    post "/contact/foi", {}

    response.body.should include("Please check the form")
  end

  it "should not accept spam (ie requests with val field filled in)" do
    visit "/contact/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    fill_in "Provide a detailed description of the information you're seeking", :with => "test foi request"
    fill_in "val", :with => "test val"
    click_on "Submit Freedom of Information request"

    page.status_code.should == 400
  end

  it "should show an error message when the support app isn't available" do
    support_isnt_available

    visit "/contact/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    fill_in "Provide a detailed description of the information you're seeking", :with => "test foi request"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/contact/foi"

    page.status_code.should == 503
  end

  it "should not proceed if the user hasn't filled in all required FOI fields" do
    visit "/contact/foi"

    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "Confirm your email address", :with => "a@a.com"
    click_on "Submit Freedom of Information request"

    i_should_be_on "/contact/foi"

    find_field('Your name').value.should eq 'test name'
    find_field('Your email address').value.should eq 'a@a.com'
    find_field('Confirm your email address').value.should eq 'a@a.com'

    no_web_calls_should_have_been_made
  end

end
