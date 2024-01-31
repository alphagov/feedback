require "rails_helper"
require "gds_api/test_helpers/support"
require "gds_api/test_helpers/support_api"

def fill_in_valid_contact_details_and_description
  fill_in "Your name", with: "test name"
  fill_in "Your email address", with: "a@a.com"
  fill_in "textdetails", with: "test text details"
end

def contact_submission_should_be_successful
  click_on "Send message"
  i_should_be_on "/contact/govuk/thankyou"
  expect(page).to have_content("Your message has been sent")
end

def anonymous_submission_should_be_successful
  click_on "Send message"
  i_should_be_on "/contact/govuk/anonymous-feedback/thankyou"
  expect(page).to have_content("Thank you for contacting GOV.UK")
end

RSpec.describe "Contact", type: :request do
  include GdsApi::TestHelpers::Support
  include GdsApi::TestHelpers::SupportApi

  it "should display an index page" do
    visit "/contact"
    expect(page).to have_title "Find contact details for services - GOV.UK"
  end

  it "should let the user submit a request with contact details" do
    stub_post = stub_support_named_contact_creation(
      requester: { name: "test name", email: "a@a.com" },
      details: "test text details",
      user_specified_url: nil,
      link: nil,
      javascript_enabled: false,
      user_agent: nil,
      referrer: nil,
      url: "#{Plek.new.website_root}/contact/govuk",
      path: "/contact/govuk",
    )

    visit "/contact/govuk"
    expect(page).to have_title "Contact GOV.UK"

    choose "location-0" # Selects the 'The whole site' radio button
    fill_in_valid_contact_details_and_description
    contact_submission_should_be_successful

    assert_requested(stub_post)
  end

  it "should let the user submit an anonymous request" do
    stub_post = stub_support_api_long_form_anonymous_contact_creation(
      details: "test text details",
      link: nil,
      user_specified_url: nil,
      javascript_enabled: false,
      user_agent: nil,
      referrer: nil,
      url: "#{Plek.new.website_root}/contact/govuk",
      path: "/contact/govuk",
    )

    visit "/contact/govuk"

    choose "location-0" # Selects the 'The whole site' radio button
    fill_in "textdetails", with: "test text details"
    anonymous_submission_should_be_successful

    assert_requested(stub_post)
  end

  it "should show an error message when the support app isn't available" do
    stub_support_isnt_available

    visit "/contact/govuk"

    choose "location-1" # Selects the 'A specific page' radio button
    fill_in_valid_contact_details_and_description
    fill_in "link", with: "some url"
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    expect(page.status_code).to eq(503)
  end

  it "should still work even if the request doesn't have correct form params" do
    post "/contact/govuk", params: {}

    expect(response.body).to include("Please check the form")
  end

  it "should not proceed if the user hasn't filled in all required fields" do
    visit "/contact/govuk"

    choose "location-0" # Selects the 'The whole site' radio button
    fill_in "Your name", with: "test name"
    fill_in "Your email address", with: "a@a.com"
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    expect(find_field("Your name").value).to eq "test name"
    expect(find_field("Your email address").value).to eq "a@a.com"

    no_post_calls_should_have_been_made
  end

  it "should not let the user submit a request with email without name" do
    visit "/contact/govuk"

    choose "location-0" # Selects the 'The whole site' radio button
    fill_in "Your email address", with: "a@a.com"
    fill_in "textdetails", with: "test text details"
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    expect(find_field("Your email address").value).to eq "a@a.com"
    expect(find_field("textdetails").value).to eq "test text details"

    no_post_calls_should_have_been_made
  end

  it "should not let the user submit a request with name without email" do
    visit "/contact/govuk"

    choose "location-0" # Selects the 'The whole site' radio button
    fill_in "Your name", with: "test name"
    fill_in "textdetails", with: "test text details"
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    expect(find_field("Your name").value).to eq "test name"
    expect(find_field("textdetails").value).to eq "test text details"

    no_post_calls_should_have_been_made
  end

  it "should let the user submit a request with a link" do
    stub_support_named_contact_creation

    visit "/contact/govuk"

    choose "location-1" # # Selects the 'A specific page' radio button
    fill_in_valid_contact_details_and_description
    fill_in "link", with: "some url"
    click_on "Send message"

    i_should_be_on "/contact/govuk/thankyou"

    expect(page).to have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")

    assert_requested(:post, %r{/named_contacts}) do |request|
      response = JSON.parse(request.body)["named_contact"]
      response["link"] == "some url"
    end
  end

  it "should escape user malicious user input when rendering it back to the user" do
    visit "/contact/govuk"
    malicious_input = "<script>alert(0)</script>"

    choose "location-0" # # Selects the 'The whole site' radio button
    fill_in "Your name", with: malicious_input
    fill_in "Your email address", with: malicious_input
    fill_in "textdetails", with: malicious_input
    click_on "Send message"

    # submission isn't accepted because email address is invalid
    i_should_be_on "/contact/govuk"

    expect(page.html).to include("&lt;script&gt;alert(0)&lt;/script&gt;")
    expect(page.html).not_to include(malicious_input)

    no_post_calls_should_have_been_made
  end

  it "should include the user agent if available" do
    stub_support_named_contact_creation

    # Using Rack::Test to allow setting the user agent.
    params = {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details",
      },
    }
    headers = { "HTTP_USER_AGENT" => "T1000 (Bazinga)" }
    post("/contact/govuk", params:, headers:)

    assert_requested(:post, %r{/named_contacts}) do |request|
      response = JSON.parse(request.body)["named_contact"]
      response["user_agent"] == "T1000 (Bazinga)"
    end
  end

  it "should include the Access-Control-Allow-Origin if the request came from .gov.uk" do
    stub_support_named_contact_creation

    params = {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details",
      },
    }
    headers = { "ORIGIN" => "https://assets.publishing.service.gov.uk" }
    post("/contact/govuk", params:, headers:)

    assert_requested(:post, %r{/named_contacts}) do |_request|
      response.headers["Access-Control-Allow-Origin"] == "https://assets.publishing.service.gov.uk"
    end
  end

  it "shouldn't include the Access-Control-Allow-Origin if the request did not come from .gov.uk" do
    stub_support_named_contact_creation

    params = {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details",
      },
    }

    headers = { "ORIGIN" => "https://not-gov.uk" }

    post("/contact/govuk", params:, headers:)

    assert_requested(:post, %r{/named_contacts}) do |_request|
      response.headers["Access-Control-Allow-Origin"].nil?
    end
  end

  it "should include the referrer if present in the contact params" do
    stub_support_named_contact_creation

    params = {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details",
        referrer: "https://www.dev.gov.uk/referring_url",
      },
    }
    post("/contact/govuk", params:)

    assert_requested(:post, %r{/named_contacts}) do |request|
      response = JSON.parse(request.body)["named_contact"]
      response["referrer"] == "https://www.dev.gov.uk/referring_url"
    end
  end

  it "should include the referrer if present in the post" do
    stub_support_named_contact_creation

    params = {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details",
      },
      referrer: "https://www.dev.gov.uk/referring_url",
    }
    post("/contact/govuk", params:)

    assert_requested(:post, %r{/named_contacts}) do |request|
      response = JSON.parse(request.body)["named_contact"]
      response["referrer"] == "https://www.dev.gov.uk/referring_url"
    end
  end

  it "should include the referrer from the request" do
    stub_support_named_contact_creation

    params = {
      contact: {
        query: "report-problem",
        link: "www.test.com",
        location: "specific",
        name: "test name",
        email: "test@test.com",
        textdetails: "test text details",
      },
    }
    post "/contact/govuk", params:, headers: { "HTTP_REFERER" => "https://www.dev.gov.uk/referring_url" }

    assert_requested(:post, %r{/named_contacts}) do |request|
      response = JSON.parse(request.body)["named_contact"]
      response["referrer"] == "https://www.dev.gov.uk/referring_url"
    end
  end

  it "should have a cookie with the previous page page before filling the form", js: true do
    visit "/contact"
    click_on "GOV.UK form"

    stub_support_named_contact_creation

    fill_in_valid_contact_details_and_description
    click_on "Send message"

    i_should_be_on "/contact/govuk/thankyou"

    click_on "Return to the GOV.UK home page"

    cookies = page.driver.browser.manage.all_cookies
    contact_referrer_cookie = cookies.find { |c| c[:name] == "govuk_contact_referrer" }
    expect(contact_referrer_cookie).not_to be_nil
    expect(contact_referrer_cookie[:value]).to match(/\/thankyou$/)
  end

  it "should have the GA4 form tracker on the form" do
    visit "/contact/govuk"

    expect(page).to have_selector(".contact-form[data-module=ga4-form-tracker]")
    expect(page).to have_selector("#link[data-ga4-form-include-input]")

    form = page.first(".contact-form")
    ga4_data = JSON.parse(form["data-ga4-form"])

    expect(ga4_data["event_name"]).to eq "form_response"
    expect(ga4_data["type"]).to eq "contact"
    expect(ga4_data["section"]).to eq "What's it to do with?"
    expect(ga4_data["action"]).to eq "Send message"
    expect(ga4_data["tool_name"]).to eq "Contact GOV.UK"
  end

  it "should have the GA4 auto tracker on the thank you pages" do
    visit "/contact/govuk/anonymous-feedback/thankyou"

    expect(page).to have_selector("p[data-module=ga4-auto-tracker]")

    ga4_auto_element = page.first("p[data-module=ga4-auto-tracker]")
    ga4_data = JSON.parse(ga4_auto_element["data-ga4-auto"])

    expect(ga4_data["event_name"]).to eq "form_complete"
    expect(ga4_data["type"]).to eq "contact"
    expect(ga4_data["text"]).to eq "Thank you for contacting GOV.UK"
    expect(ga4_data["action"]).to eq "complete"
    expect(ga4_data["tool_name"]).to eq "Contact GOV.UK"

    visit "/contact/govuk/thankyou"

    expect(page).to have_selector("p[data-module=ga4-auto-tracker]")

    ga4_auto_element = page.first("p[data-module=ga4-auto-tracker]")
    ga4_data = JSON.parse(ga4_auto_element["data-ga4-auto"])

    expect(ga4_data["event_name"]).to eq "form_complete"
    expect(ga4_data["type"]).to eq "contact"
    expect(ga4_data["text"]).to eq "Your message has been sent, and the team will get back to you to answer any questions as soon as possible."
    expect(ga4_data["action"]).to eq "complete"
    expect(ga4_data["tool_name"]).to eq "Contact GOV.UK"
  end

  it "should have the GA4 auto tracker on form error" do
    visit "/contact/govuk"

    choose "location-1" # Selects the 'A specific page' radio button
    fill_in "Your name", with: ""
    fill_in "Your email address", with: ".@a.com"
    fill_in "textdetails", with: ""
    fill_in "link", with: ""
    click_on "Send message"

    i_should_be_on "/contact/govuk"

    ga4_auto_element = page.first("form div[data-module=ga4-auto-tracker]")
    ga4_data = JSON.parse(ga4_auto_element["data-ga4-auto"])

    expect(ga4_data["event_name"]).to eq "form_error"
    expect(ga4_data["type"]).to eq "contact"
    expect(ga4_data["text"]).to eq "The link field cannot be empty, The message field cannot be empty, The email address must be valid, The name field cannot be empty"
    expect(ga4_data["section"]).to eq "What's it to do with?, What are the details?, If you want a reply (optional), If you want a reply (optional)"
    expect(ga4_data["tool_name"]).to eq "Contact GOV.UK"
  end
end
