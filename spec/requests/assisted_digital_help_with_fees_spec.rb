require 'rails_helper'

RSpec.describe "Assisted digital help with fees submission", type: :request do
  before do
    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*})
    # Set auth to nil, and this won't try to incur extra requests
    allow(GoogleCredentials).to receive(:authorization).and_return nil
  end

  it "shows the standard thank you message on success" do
    submit_service_feedback

    expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
    get contact_anonymous_feedback_thankyou_path

    expect(response.body).to include("Thank you for your feedback.")
  end

  it "should accept invalid submissions, just not do anything with them (because the form itself lives
    in the feedback app and re-rendering it with the user's original feedback isn't straightforward" do
    submit_service_feedback params: {}

    expect(response).to redirect_to(contact_anonymous_feedback_thankyou_path)
    get contact_anonymous_feedback_thankyou_path

    expect(response.body).to include("Thank you for your feedback.")
  end

  it "sends the data to google" do
    submit_service_feedback

    expect(a_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).with { |request|
      JSON.parse(request.body)["values"][0][2] == "it was fine"
    }).to have_been_requested
  end

  it "should include the user_agent if available" do
    submit_service_feedback(headers: { "HTTP_USER_AGENT" => "Shamfari/3.14159 (Fooey)" })

    expect(a_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).with { |request|
      JSON.parse(request.body)["values"][0][4] == "Shamfari/3.14159 (Fooey)"
    }).to have_been_requested
  end

  it "should handle the google storage service failing" do
    stub_request(:post, %r{https://sheets.googleapis.com/v4/spreadsheets/*}).to_return(status: 403)

    submit_service_feedback

    # the user should see the standard GOV.UK 503 page
    expect(response.code).to eq("503")
  end

  def submit_service_feedback(params: valid_params, headers: {})
    post "/contact/govuk/assisted-digital-help-with-fees-survey-feedback", params, headers
  end

  def valid_params
    {
      service_feedback: {
        assistance: 'no',
        service_satisfaction_rating: '5',
        improvement_comments: 'it was fine',
        slug: "some-transaction",
        url: "https://www.gov.uk/done/some-transaction",
        referrer: "https://www.some-transaction.service.gov/uk/completed",
      }
    }
  end
end
