require 'rails_helper'
require 'gds_api/test_helpers/support'

RSpec.describe "FOI", type: :request do
  include GdsApi::TestHelpers::Support

  def fill_in_valid_credentials
    fill_in "Your name", with: "test name"
    fill_in "Your email address", with: "a@a.com"
    fill_in "Confirm your email address", with: "a@a.com"
  end

  it "should let the user submit a FOI request" do
    stub_post = stub_support_foi_request_creation(
      requester: {
        name: "test name",
        email: "a@a.com"
      },
      details: "test foi request",
      url: "#{Plek.new.website_root}/contact/foi"
    )

    visit "/contact/foi"
    expect(page).to have_title "Make a Freedom of Information request"

    fill_in "Your name", with: "test name"
    fill_in "Your email address", with: "a@a.com"
    fill_in "Confirm your email address", with: "a@a.com"
    fill_in "Include a detailed description of the information you're looking for. Don't include any personal or financial information.", with: "test foi request"
    click_on "Submit your Freedom of Information request"

    i_should_be_on "/contact/govuk/thankyou"

    expect(page).to have_content("Your message has been sent, and the team will get back to you to answer any questions as soon as possible.")
    assert_requested(stub_post)
  end

  it "should still work even if the request doesn't have correct form params" do
    post "/contact/foi", params: {}

    expect(response.body).to include("Please check the form")
  end

  it "should not accept spam (ie requests with val field filled in)" do
    visit "/contact/foi"

    fill_in "Your name", with: "test name"
    fill_in "Your email address", with: "a@a.com"
    fill_in "Confirm your email address", with: "a@a.com"
    fill_in "Include a detailed description of the information you're looking for. Don't include any personal or financial information.", with: "test foi request"
    fill_in "val", with: "test val"
    click_on "Submit your Freedom of Information request"

    expect(page.status_code).to eq(400)
  end

  it "should show an error message when the support app isn't available" do
    support_isnt_available

    visit "/contact/foi"

    fill_in "Your name", with: "test name"
    fill_in "Your email address", with: "a@a.com"
    fill_in "Confirm your email address", with: "a@a.com"
    fill_in "Include a detailed description of the information you're looking for. Don't include any personal or financial information.", with: "test foi request"
    click_on "Submit your Freedom of Information request"

    i_should_be_on "/contact/foi"

    expect(page.status_code).to eq(503)
  end

  it "should not proceed if the user hasn't filled in all required FOI fields" do
    visit "/contact/foi"

    fill_in "Your name", with: "test name"
    fill_in "Your email address", with: "a@a.com"
    fill_in "Confirm your email address", with: "a@a.com"
    click_on "Submit your Freedom of Information request"

    i_should_be_on "/contact/foi"

    expect(find_field('Your name').value).to eq 'test name'
    expect(find_field('Your email address').value).to eq 'a@a.com'
    expect(find_field('Confirm your email address').value).to eq 'a@a.com'

    expect(a_request(:post, '/contact/foi')).not_to have_been_made
  end
end
