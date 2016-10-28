require 'rails_helper'

RSpec.describe "Assisted digital help with fees submission", type: :request do
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
