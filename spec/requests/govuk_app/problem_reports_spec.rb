require "rails_helper"
require "gds_api/test_helpers/support_api"

RSpec.describe "GOV.UK app problem reports", type: :request do
  include GdsApi::TestHelpers::SupportApi

  let(:params) do
    {
      giraffe: "",
      phone: "iPhone 15",
      app_version: "1.0",
      trying_to_do: "Something",
      what_happened: "Something bad",
      reply: "yes",
      name: "Zeus",
      email: "someone@something.com",
    }
  end
  let(:body) do
    <<~MULTILINE_STRING
      [Requester]
      Zeus <someone@something.com>

      [Phone]
      iPhone 15

      [App version]
      1.0

      [What were you trying to do?]
      Something

      [What happened?]
      Something bad
    MULTILINE_STRING
  end

  describe "#new" do
    it "should render the form" do
      get "/contact/govuk-app/report-problem"
      expect(response).to render_template("new")
    end
  end

  describe "#create" do
    it "should submit ticket and redirect to confirmation page" do
      request = stub_support_api_valid_raise_support_ticket(
        {
          subject: "Problem report",
          priority: "normal",
          tags: %w[govuk_app govuk_app_problem_report],
          description: body,
          requester: {
            email: "someone@something.com",
            name: "Zeus",
          },
        },
      )

      post "/contact/govuk-app/report-problem", params: { problem_report: params }

      expect(request).to have_been_made
      expect(response).to redirect_to("/contact/govuk-app/confirmation")
    end

    it "should re-render form and not submit ticket if submission invalid" do
      request = stub_any_support_api_call
      params[:what_happened] = ""
      post "/contact/govuk-app/report-problem", params: { problem_report: params }

      expect(request).to_not have_been_made
      expect(response).to render_template("new")
    end
  end
end
