require 'rails_helper'
require 'gds_api/test_helpers/support'
require 'gds_api/test_helpers/support_api'

RSpec.describe "Service feedback submission", type: :request do
  include GdsApi::TestHelpers::Support
  include GdsApi::TestHelpers::SupportApi

  it "should pass the feedback through the support-api" do
    stub_post = stub_support_api_service_feedback_creation(
      service_satisfaction_rating: 5,
      details: "the transaction is ace",
      slug: "some-transaction",
      user_agent: nil,
      javascript_enabled: false,
      referrer: "https://www.some-transaction.service.gov/uk/completed",
      path: "/done/some-transaction",
      url: "https://www.gov.uk/done/some-transaction",
    )

    submit_service_feedback

    expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
    get contact_anonymous_feedback_thankyou_path

    expect(response.body).to include("Thank you for your feedback.")
    assert_requested(stub_post)
  end

  it "should include the user_agent if available" do
    stub_support_api_service_feedback_creation

    submit_service_feedback("HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)")

    assert_requested(:post, %r{/service-feedback}) do |request|
      JSON.parse(request.body)["service_feedback"]["user_agent"] == "Shamfari/3.14159 (Fooey)"
    end
  end

  it "should include the referrer if available" do
    stub_support_api_service_feedback_creation

    submit_service_feedback

    assert_requested(:post, %r{/service-feedback}) do |request|
      JSON.parse(request.body)["service_feedback"]["referrer"] == "https://www.some-transaction.service.gov/uk/completed"
    end
  end

  it "should accept invalid submissions, just not do anything with them (because the form itself lives
    in the feedback app and re-rendering it with the user's original feedback isn't straightforward" do
    post "/contact/govuk/service-feedback", params: {}

    expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
    get contact_anonymous_feedback_thankyou_path

    expect(response.body).to include("Thank you for your feedback.")
  end

  it "should handle the support-api being unavailable" do
    support_api_isnt_available

    submit_service_feedback

    # the user should see the standard GOV.UK 503 page
    expect(response.code).to eq("503")
  end

  def submit_service_feedback(headers = {})
    post "/contact/govuk/service-feedback", params: valid_params, headers: headers
  end

  def valid_params
    {
      service_feedback: {
        service_satisfaction_rating: "5",
        improvement_comments: "the transaction is ace",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
        referrer: "https://www.some-transaction.service.gov/uk/completed",
      }
    }
  end
end
