require 'spec_helper'

def fill_in_valid_contact_details_and_description
  fill_in "Your name", :with => "test name"
  fill_in "Your email address", :with => "a@a.com"
  fill_in "textdetails", :with => "test text details"
end

def contact_submission_should_be_successful
  click_on "Send message"
  i_should_be_on "/contact/govuk/thankyou"
  page.should have_content("Your message has been sent")
end

def anonymous_submission_should_be_successful
  click_on "Send message"
  i_should_be_on "/contact/govuk/anonymous-feedback/thankyou"
  page.should have_content("Thank you for your feedback")
end

describe "Contact" do
  it "should display an index page" do
    visit "/contact"
    expect(page).to have_title "Contact"
  end

  include GdsApi::TestHelpers::Support
  it "should let the user submit a request with contact details" do
    stub_post = stub_support_named_contact_creation(
      requester: { name: "test name", email: "a@a.com" },
      details: "test text details",
      link: nil,
      javascript_enabled: false,
      user_agent: nil,
      referrer: nil,
      url: "#{Plek.new.website_root}/contact/govuk"
    )

    visit "/contact/govuk"
    expect(page).to have_title "Contact GOV.UK"

    choose "location-all"
    fill_in_valid_contact_details_and_description
    contact_submission_should_be_successful

    assert_requested(stub_post)
  end

  it "should not accept spam (ie a request with val field filled in)" do
    visit "/contact/govuk"

    choose "location-all"
    fill_in_valid_contact_details_and_description
    fill_in "val", :with => "test val"
    click_on "Send message"

    no_web_calls_should_have_been_made

    page.status_code.should == 400
  end

  it "should let the user submit an anonymous request" do
    stub_post = stub_support_long_form_anonymous_contact_creation(
      details: "test text details",
      link: nil,
      javascript_enabled: false,
      user_agent: nil,
      referrer: nil,
      url: "#{Plek.new.website_root}/contact/govuk"
    )

    visit "/contact/govuk"

    choose "location-all"
    fill_in "textdetails", :with => "test text details"
    anonymous_submission_should_be_successful

    assert_requested(stub_post)
  end

  it "should show an error message when the support app isn't available" do
    support_isnt_available

    visit "/contact/govuk"

    choose "location-specific"
    fill_in_valid_contact_details_and_description
    fill_in "link", :with => "some url"
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    page.status_code.should == 503
  end

  it "should still work even if the request doesn't have correct form params" do
    post "/contact/govuk", {}

    response.body.should include("Please check the form")
  end

  it "should not proceed if the user hasn't filled in all required fields" do
    visit "/contact/govuk"

    choose "location-all"
    fill_in "Your name", :with => "test name"
    fill_in "Your email address", :with => "a@a.com"
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    find_field('Your name').value.should eq 'test name'
    find_field('Your email address').value.should eq 'a@a.com'

    no_web_calls_should_have_been_made
  end

  it "should not let the user submit a request with email without name" do
    visit "/contact/govuk"

    choose "location-all"
    fill_in "Your email address", :with => "a@a.com"
    fill_in "textdetails", :with => "test text details"
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    find_field('Your email address').value.should eq 'a@a.com'
    find_field('textdetails').value.should eq 'test text details'

    no_web_calls_should_have_been_made
  end

  it "should not let the user submit a request with name without email" do
    visit "/contact/govuk"

    choose "location-all"
    fill_in "Your name", :with => "test name"
    fill_in "textdetails", :with => "test text details"
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    find_field('Your name').value.should eq 'test name'
    find_field('textdetails').value.should eq 'test text details'

    no_web_calls_should_have_been_made
  end

  it "should let the user submit a request with a link" do
    stub_support_named_contact_creation

    visit "/contact/govuk"

    choose "location-specific"
    fill_in_valid_contact_details_and_description
    fill_in "link", :with => "some url"
    click_on "Send message"

    i_should_be_on "/contact/govuk/thankyou"

    page.should have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")

    assert_requested(:post, %r{/named_contacts}) do |request|
      response = JSON.parse(request.body)["named_contact"]
      response["link"] == "some url"
    end
  end

  it "should include the user agent if available" do
    stub_support_named_contact_creation

    # Using Rack::Test to allow setting the user agent.
    post "/contact/govuk", {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details"
      }
    }, {"HTTP_USER_AGENT" => "T1000 (Bazinga)"}

    assert_requested(:post, %r{/named_contacts}) do |request|
      response = JSON.parse(request.body)["named_contact"]
      response["user_agent"] == "T1000 (Bazinga)"
    end
  end

  it "should include the referrer if available" do
    stub_support_named_contact_creation

    # Using Rack::Test to allow setting the user agent.
    post "/contact/govuk", {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details",
        referrer: "https://www.dev.gov.uk/referring_url"
      }
    }

    assert_requested(:post, %r{/named_contacts}) do |request|
      response = JSON.parse(request.body)["named_contact"]
      response["referrer"] == "https://www.dev.gov.uk/referring_url"
    end
  end
end
