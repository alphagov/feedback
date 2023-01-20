require "rails_helper"
require "gds_api/test_helpers/support"
require "gds_api/test_helpers/support_api"
require "gds_api/test_helpers/content_store"

RSpec.describe "Service feedback submission", type: :request do
  include GdsApi::TestHelpers::Support
  include GdsApi::TestHelpers::SupportApi
  include GdsApi::TestHelpers::ContentStore

  before do
    stub_content_store_has_item("/#{slug}", schema_name: format)
  end

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

    expect(response.body).to include("Thank you for contacting GOV.UK")
    assert_requested(stub_post)
  end

  it "should include the user_agent if available" do
    stub_support_api_service_feedback_creation

    submit_service_feedback(headers: { "HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)" })

    assert_requested(:post, %r{/service-feedback}) do |request|
      JSON.parse(request.body)["service_feedback"]["user_agent"] == "Shamfari/3.14159 (Fooey)"
    end
  end

  context "the referrer value" do
    before do
      stub_support_api_service_feedback_creation
    end

    it "uses the value in the service_feedback params" do
      posted_params = valid_params
      posted_params[:service_feedback][:referrer] = "http://referrer.example.com/i-came-from-here"
      posted_params.delete(:referrer)
      submit_service_feedback(params: posted_params)

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end
    end

    it "uses the value in the posted params" do
      posted_params = valid_params
      posted_params[:service_feedback].delete(:referrer)
      posted_params[:referrer] = "http://referrer.example.com/i-came-from-here"
      submit_service_feedback(params: posted_params)

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end
    end

    it "uses the value in the request headers params" do
      posted_params = valid_params
      posted_params[:service_feedback].delete(:referrer)
      posted_params.delete(:referrer)
      submit_service_feedback(params: posted_params, headers: { "HTTP_REFERER" => "http://referrer.example.com/i-came-from-here" })

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end
    end

    it "prefers the value in the service_feedback params if all options are present" do
      posted_params = valid_params
      posted_params[:service_feedback][:referrer] = "http://referrer.example.com/i-came-from-here"
      posted_params[:referrer] = "http://referrer.example.com/i-did-not-come-from-here"
      submit_service_feedback(params: posted_params, headers: { "HTTP_REFERER" => "http://referrer.example.com/i-did-not-come-from-here-either" })

      assert_requested(:post, %r{/service-feedback}) do |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      end
    end
  end

  it "should handle the support-api being unavailable" do
    stub_support_api_isnt_available

    submit_service_feedback

    # the user should see the standard GOV.UK 503 page
    expect(response.code).to eq("503")
  end

  def submit_service_feedback(params: valid_params, headers: {})
    post "/done/some-transaction", params:, headers:
  end

  def valid_params
    {
      service_feedback: {
        service_satisfaction_rating: "5",
        improvement_comments: "the transaction is ace",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
        referrer: "https://www.some-transaction.service.gov/uk/completed",
      },
    }
  end

  def format
    "completed_transaction"
  end

  def slug
    "done/some-transaction"
  end
end
