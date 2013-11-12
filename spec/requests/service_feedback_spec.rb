require 'spec_helper'

describe "Service feedback submission" do
  include GdsApi::TestHelpers::Support

  it "should pass the feedback through the support API" do
    stub_post = stub_support_service_feedback_creation(
      service_satisfaction_rating: 5,
      improvement_comments: "the transaction is ace",
      slug: "done/some-transaction",
      user_agent: nil,
      javascript_enabled: false
    )

    submit_service_feedback

    expect(response.body).to include("Thank you for your feedback.")
    assert_requested(stub_post)
  end

  it "should include the user_agent if available" do
    stub_support_service_feedback_creation

    submit_service_feedback("HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)")

    assert_requested(:post, %r{/service_feedback}) do |request|
      JSON.parse(request.body)["service_feedback"]["user_agent"] == "Shamfari/3.14159 (Fooey)"
    end
  end

  it "should pass the varnish ID through to the support app if set" do
    stub_support_service_feedback_creation

    submit_service_feedback("HTTP_X_VARNISH" => "12345")

    assert_requested(:post, %r{/service_feedback}) do |request|
      request.headers["X-Varnish"] == "12345"
    end
  end

  it "should accept invalid submissions, just not do anything with them (because the form itself lives
    in the feedback app and re-rendering it with the user's original feedback isn't straightforward" do
    post "/contact/govuk/service-feedback", {}

    response.body.should include("Thank you for your feedback.")
  end

  it "should handle the support app being unavailable" do
    support_isnt_available

    submit_service_feedback

    # the user should see the standard GOV.UK 503 page
    expect(response.code).to eq("503")
  end

  def submit_service_feedback(headers = {})
    post "/contact/govuk/service-feedback", valid_params, headers
  end

  def valid_params
    {
      service_feedback: {
        service_satisfaction_rating: "5",
        improvement_comments: "the transaction is ace",
        slug: "done/some-transaction"
      }
    }
  end
end
