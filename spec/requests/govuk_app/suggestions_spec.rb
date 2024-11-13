require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe "GOV.UK app suggestions", type: :request do
  include GdsApi::TestHelpers::SupportApi

  let(:params) do
    {
      giraffe: "",
      details: "Something good",
      reply: "yes",
      name: "Zeus",
      email: "someone@something.com",
    }
  end
  let(:body) do
    <<~MULTILINE_STRING
      [Requester]
      Zeus <someone@something.com>

      [What is your suggestion?]
      Something good
    MULTILINE_STRING
  end

  describe "#new" do
    it "should render the form" do
      get "/contact/govuk-app/make-suggestion"
      expect(response).to render_template("new")
    end
  end

  describe "#create" do
    it "should submit ticket and redirect to confirmation page" do
      request = stub_support_api_valid_raise_support_ticket(
        {
          subject: "Suggestion",
          priority: "medium",
          tags: %w[app_form],
          description: body,
          requester: {
            email: "someone@something.com",
            name: "Zeus",
          },
        },
      )

      post "/contact/govuk-app/make-suggestion", params: { suggestion: params }

      expect(request).to have_been_made
      expect(response).to redirect_to("/contact/govuk-app/confirmation")
    end
  end
end
