require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe "Assisted digital help with fees submission", type: :request do
  include GdsApi::TestHelpers::SupportApi
  include ActiveSupport::Testing::TimeHelpers

  before do
    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*})
    stub_support_api_service_feedback_creation
    # Set auth to nil, and this won't try to incur extra requests
    allow(GoogleCredentials).to receive(:authorization).and_return nil
  end

  it "shows the standard thank you message on success" do
    submit_service_feedback

    expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
    get contact_anonymous_feedback_thankyou_path

    expect(response.body).to include("Thank you for your feedback")
  end

  it "should accept invalid submissions, just not do anything with them (because the form itself lives
    in the feedback app and re-rendering it with the user's original feedback isn't straightforward" do
    submit_service_feedback params: {}

    expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
    get contact_anonymous_feedback_thankyou_path

    expect(response.body).to include("Thank you for your feedback")
  end

  it "sends the full assisted digital feedback data to google" do
    the_past = 13.years.ago.change(usec: 0)
    travel_to(the_past) do
      submit_service_feedback

      expect(a_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).with { |request|
        values = JSON.parse(request.body)["values"][0]
        values == [
          "yes",
          "someone helped me",
          "friend-relative",
          nil,
          nil,
          nil,
          5,
          "it was fine",
          "some-transaction",
          nil,
          false,
          "https://www.some-transaction.service.gov/uk/completed",
          "/done/some-transaction",
          "https://www.gov.uk/done/some-transaction",
          the_past.iso8601(3),
        ]
      }).to have_been_requested
    end
  end

  it "sends a subset of the data to the support api as service feedback" do
    service_feedback_request = stub_support_api_service_feedback_creation(
      service_satisfaction_rating: 5,
      details: "it was fine",
      slug: "some-transaction",
      user_agent: nil,
      javascript_enabled: false,
      referrer: "https://www.some-transaction.service.gov/uk/completed",
      path: "/done/some-transaction",
      url: "https://www.gov.uk/done/some-transaction",
    )
    submit_service_feedback

    expect(service_feedback_request).to have_been_requested
  end

  context "the referrer value" do
    before do
      stub_support_api_service_feedback_creation
    end

    it "uses the referrer from the posted params" do
      posted_params = valid_params
      posted_params[:referrer] = "http://referrer.example.com/i-came-from-here"
      posted_params[:service_feedback].delete(:referrer)
      submit_service_feedback(params: posted_params)

      expect(a_request(:post, %r{/service-feedback}).with { |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      }).to have_been_requested
    end

    it "uses the referrer from the service_feedback params" do
      posted_params = valid_params
      posted_params.delete(:referrer)
      posted_params[:service_feedback][:referrer] = "http://referrer.example.com/i-came-from-here"
      submit_service_feedback(params: posted_params)

      expect(a_request(:post, %r{/service-feedback}).with { |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      }).to have_been_requested
    end

    it "uses the referrer from the request header" do
      posted_params = valid_params
      posted_params.delete(:referrer)
      posted_params[:service_feedback].delete(:referrer)
      submit_service_feedback(params: posted_params, headers: { "HTTP_REFERER" => "http://referrer.example.com/i-came-from-here" })

      expect(a_request(:post, %r{/service-feedback}).with { |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      }).to have_been_requested
    end

    it "prefers the referrer from the service_feedback params if all are present header" do
      posted_params = valid_params
      posted_params[:referrer] = "http://referrer.example.com/i-did-not-come-from-here"
      posted_params[:service_feedback][:referrer] = "http://referrer.example.com/i-came-from-here"
      submit_service_feedback(params: posted_params, headers: { "HTTP_REFERER" => "http://referrer.example.com/i-did-not-come-from-here-either" })

      expect(a_request(:post, %r{/service-feedback}).with { |request|
        JSON.parse(request.body)["service_feedback"]["referrer"] == "http://referrer.example.com/i-came-from-here"
      }).to have_been_requested
    end
  end

  it "should include the user_agent if available" do
    submit_service_feedback(headers: { "HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)" })

    expect(a_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).with { |request|
      JSON.parse(request.body)["values"][0][9] == "Shamfari/3.14159 (Fooey)"
    }).to have_been_requested
  end

  it "should handle the google storage service failing" do
    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).to_return(status: 403)

    submit_service_feedback

    # the user should see the standard GOV.UK 503 page
    expect(response.code).to eq("503")
  end

  def submit_service_feedback(params: valid_params, headers: {})
    post "/contact/govuk/assisted-digital-survey-feedback", params: params, headers: headers
  end

  def valid_params
    {
      service_feedback: {
        assistance_received: "yes",
        assistance_received_comments: "someone helped me",
        assistance_provided_by: "friend-relative",
        service_satisfaction_rating: "5",
        improvement_comments: "it was fine",
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
      },
      referrer: "https://www.some-transaction.service.gov/uk/completed",
    }
  end
end
